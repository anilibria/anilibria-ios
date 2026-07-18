import Combine
import UIKit
import AVKit

// MARK: - View Controller

final class PlayerViewController: BaseViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pipButton: UIButton!
    @IBOutlet var playPauseButton: RippleButton!
    @IBOutlet var playPauseIconView: UIImageView!
    @IBOutlet var seriesSelectorLabel: UILabel!
    @IBOutlet var timeLeftLabel: UILabel!
    @IBOutlet var elapsedTimeLabel: UILabel!
    @IBOutlet var videoSliderView: PlayerProgressView!
    @IBOutlet var playerContainer: PlayerContainerView!
    @IBOutlet var nextContainer: UIView!
    @IBOutlet var previousContainer: UIView!
    @IBOutlet var loaderContainer: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var skipContainer: SkipContainerView!
    @IBOutlet var topShadowView: ShadowView!
    @IBOutlet var bottomShadowView: ShadowView!

    var playerView: (any Player)!
    private let airplayView = AVRoutePickerView()
    private var pictureInPictureController: AVPictureInPictureController?
    private let timeFormatter = FormatterFactory.time.create()
    private var bag: AnyCancellable?
    private var hideUISubscriber: AnyCancellable?
    private var pipObservation: Any?
    private var needsPlay = false
    private var needsClose = false
    private let userInteractionSubject = PassthroughSubject<Void, Never>()

    #if targetEnvironment(macCatalyst)
    private var cursorHidingController: Any?
    private let volumeIndicatorView = VolumeIndicatorView()
    private var volumeIndicatorHideSubscriber: AnyCancellable?
    #endif

    private var orientation: UIInterfaceOrientationMask = .all

    let viewModel: PlayerViewModel

    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.setup()
        self.setupPlayer()
        self.setupAirPlay()
        self.setupPictureInPicture()
        #if targetEnvironment(macCatalyst)
        self.setupVolumeIndicator()
        #endif

        let font: UIFont = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        self.timeLeftLabel.font = font
        self.elapsedTimeLabel.font = font

        self.topShadowView.shadowY = 20
        self.topShadowView.shadowRadius = 40
        self.topShadowView.shadowOpacity = 1
        self.topShadowView.shadowColor = .black
        self.bottomShadowView.shadowY = -50
        self.bottomShadowView.shadowRadius = 80
        self.bottomShadowView.shadowOpacity = 1
        self.bottomShadowView.shadowColor = .black

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handle))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(panRecognizer)

        #if targetEnvironment(macCatalyst)
        self.setupCursorHiding()
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.save()
    }

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        let back = UIKeyCommand(
            input: UIKeyCommand.inputLeftArrow,
            modifierFlags: [],
            action: #selector(self.rewindBack)
        )

        let forward = UIKeyCommand(
            input: UIKeyCommand.inputRightArrow,
            modifierFlags: [],
            action: #selector(self.rewindForward)
        )

        let playPause = UIKeyCommand(
            input: UIKeyCommand.inputSpace,
            modifierFlags: [],
            action: #selector(self.playPauseAction(_:))
        )

        let search = UIKeyCommand(
            input: "f",
            modifierFlags: [.command],
            action: #selector(self.searchAction)
        )
        search.discoverabilityTitle = L10n.Common.Search.byName

        if #available(iOS 15.0, macCatalyst 15.0, *) {
            back.wantsPriorityOverSystemBehavior = true
            forward.wantsPriorityOverSystemBehavior = true
            search.wantsPriorityOverSystemBehavior = true
        }

        var commands = [playPause, back, forward, search]

        #if targetEnvironment(macCatalyst)
        let volumeUp = UIKeyCommand(
            input: UIKeyCommand.inputUpArrow,
            modifierFlags: [],
            action: #selector(self.volumeUpAction)
        )

        let volumeDown = UIKeyCommand(
            input: UIKeyCommand.inputDownArrow,
            modifierFlags: [],
            action: #selector(self.volumeDownAction)
        )

        let muteToggle = UIKeyCommand(
            input: "m",
            modifierFlags: [],
            action: #selector(self.muteToggleAction)
        )

        if #available(iOS 15.0, macCatalyst 15.0, *) {
            volumeUp.wantsPriorityOverSystemBehavior = true
            volumeDown.wantsPriorityOverSystemBehavior = true
        }

        commands.append(contentsOf: [volumeUp, volumeDown, muteToggle])
        #endif

        return commands
    }

    private func setup() {
        skipContainer.configure(with: viewModel.skipViewModel)
        viewModel.skipViewModel.skipHandler = { [weak self] time in
            self?.apply(rewind: time)
        }

        titleLabel.text = viewModel.seriesName
        needsPlay = viewModel.playOnStartup

        videoSliderView.set(duration: 0)
        setLoader(visible: true)

        viewModel.$orientation.sink { [weak self] value in
            self?.orientation = value.mask
            self?.updateOrientation()
        }.store(in: &subscribers)

        viewModel.$playItem
            .scan((nil, nil), { ($0.1, $1) })
            .sink { [weak self] (old, next) in
                if let next {
                    self?.set(playItem: next, previous: old)
                }
            }.store(in: &subscribers)

        viewModel.$playbackRate
            .sink { [weak self] rate in
                self?.playerView.set(rate: rate)
            }.store(in: &subscribers)

        #if targetEnvironment(macCatalyst)
        Publishers.CombineLatest(viewModel.$volume, viewModel.$isMuted)
            .sink { [weak self] volume, isMuted in
                guard let self else { return }
                playerView.volume = isMuted ? 0 : volume
                volumeIndicatorView.set(volume: volume, isMuted: isMuted)
            }.store(in: &subscribers)
        #endif

        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.viewModel.save()
            }.store(in: &subscribers)
    }

    private func setupPlayer() {
        self.playerContainer.addSubview(self.playerView)
        self.playerView.constraintEdgesToSuperview()

        self.playerView.getCurrentTime()
            .filter { [weak self] _ in
                !(self?.videoSliderView.isDragging ?? true)
            }
            .sink(onNext: { [weak self] time in
                guard let self else { return }
                viewModel.update(time: time)
                videoSliderView.set(progress: time)
            })
            .store(in: &subscribers)

        self.playerView.getBufferTime()
            .sink(onNext: { [weak self] time in
                self?.videoSliderView.set(buffering: time)
            })
            .store(in: &subscribers)

        self.playerView.getPlayChanges()
            .sink(onNext: { [weak self] value in
                let image: UIImage = value ? .System.pause : .System.play
                self?.playPauseIconView.image = image
                self?.viewModel.skipViewModel.isActive = value
            })
            .store(in: &subscribers)

        Publishers.CombineLatest(
            playerView.getPlayChanges(),
            userInteractionSubject.throttle(
                for: .seconds(0.5),
                scheduler: DispatchQueue.main,
                latest: true
            )
        ).sink { [weak self] isPlaiyng, _ in
            if isPlaiyng {
                self?.startAutoHiddingUI()
            } else {
                self?.stopAutoHiddingUI()
            }
        }.store(in: &subscribers)

        #if targetEnvironment(macCatalyst)
        playerView.getPlayChanges()
            .sink { [weak self] isPlaying in
                if isPlaying {
                    self?.resetCursorIdleTimer()
                } else {
                    self?.stopCursorIdleTimer()
                }
            }
            .store(in: &subscribers)
        #endif

        self.playerView.getStatusSequence()
            .sink(onNext: { [weak self] value in
                switch value {
                case .unknown, .waitingToPlay:
                    self?.setLoader(visible: true)
                default:
                    self?.setLoader(visible: false)
                }
            })
            .store(in: &subscribers)

        playerContainer.didRequestRewind = { [weak self] in
            self?.apply(rewind: $0)
        }

        videoSliderView.didSelectProgress = { [weak self] time in
            self?.playerView.set(time: time)
        }

        videoSliderView.changeValue = { [weak self] progress, duration in
            self?.updateLabels(progress: progress, duration: duration)
        }
    }

    private func startAutoHiddingUI() {
        hideUISubscriber = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink(receiveValue: { [weak self] _ in
                self?.playerContainer.uiIsVisible = false
            })
    }

    private func stopAutoHiddingUI() {
        hideUISubscriber?.cancel()
    }

    #if targetEnvironment(macCatalyst)
    private func setupCursorHiding() {
        if #available(macCatalyst 13.4, *) {
            cursorHidingController = CursorHidingController(view: view) { [weak self] isVisible in
                self?.playerContainer.uiIsVisible = isVisible
            }
        }
    }

    private func resetCursorIdleTimer() {
        if #available(macCatalyst 13.4, *) {
            (cursorHidingController as? CursorHidingController)?.resetIdleTimer()
        }
    }

    private func stopCursorIdleTimer() {
        if #available(macCatalyst 13.4, *) {
            (cursorHidingController as? CursorHidingController)?.stopIdleTimer()
        }
    }
    #endif

    func setupPictureInPicture() {
        if let layer = playerView.playerLayer,
           AVPictureInPictureController.isPictureInPictureSupported() {
            pipButton.isHidden = false
            pictureInPictureController = AVPictureInPictureController(playerLayer: layer)
            pictureInPictureController?.delegate = self

            pipObservation = pictureInPictureController?.observe(
                \AVPictureInPictureController.isPictureInPicturePossible,
                 options: [.initial, .new]
            ) { [weak self] _, change in
                self?.pipButton.isEnabled = change.newValue ?? false
            }
        } else {
            pipButton.isHidden = true
        }
    }

    private func apply(rewind time: Double) {
        guard playerView.duration != nil, time != 0 else { return }
        let newTime = videoSliderView.progress + time

        let playing = playerView.isPlaying
        if playing { playerView.togglePlay() }

        videoSliderView.set(progress: newTime)
        playerView.set(time: newTime)

        if playing { playerView.togglePlay() }
    }

    @objc private func rewindForward() {
        self.apply(rewind: 10.0)
    }

    @objc private func rewindBack() {
        self.apply(rewind: -5.0)
    }

    @objc private func searchAction() {
        if playerView.isPlaying {
            playPauseAction(self)
        }
        viewModel.showSearch()
    }

    private func setupAirPlay() {
        airplayView.tintColor = .white
        container.addSubview(airplayView)
        airplayView.constraintEdgesToSuperview()
    }

    #if targetEnvironment(macCatalyst)
    private func setupVolumeIndicator() {
        volumeIndicatorView.alpha = 0
        volumeIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(volumeIndicatorView)
        NSLayoutConstraint.activate([
            volumeIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            volumeIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    private func showVolumeIndicator() {
        volumeIndicatorHideSubscriber?.cancel()
        UIView.animate(withDuration: 0.2) {
            self.volumeIndicatorView.alpha = 1
        }
        volumeIndicatorHideSubscriber = Timer.publish(every: 1.2, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink(receiveValue: { [weak self] _ in
                UIView.animate(withDuration: 0.3) {
                    self?.volumeIndicatorView.alpha = 0
                }
            })
    }

    @objc private func volumeUpAction() {
        viewModel.changeVolume(by: 0.1)
        showVolumeIndicator()
    }

    @objc private func volumeDownAction() {
        viewModel.changeVolume(by: -0.1)
        showVolumeIndicator()
    }

    @objc private func muteToggleAction() {
        viewModel.toggleMute()
        showVolumeIndicator()
    }
    #endif

    private func updateLabels(progress: Double, duration: Double) {
        if duration == 0 {
            timeLeftLabel.text = "--:--"
            elapsedTimeLabel.text = "--:--"
        } else {
            timeLeftLabel.text = timeFormatter.string(from: progress)
            let elapsed = self.timeFormatter.string(from: duration - progress) ?? ""
            elapsedTimeLabel.text = "-\(elapsed)"
        }
    }

    private func set(playItem: PlayItem, previous: PlayItem? = nil) {
        seriesSelectorLabel.text = playItem.name
        videoSliderView.set(duration: 0)

        change(enabled: !playItem.isFirst, view: previousContainer)
        change(enabled: !playItem.isLast, view: nextContainer)

        if let url = playItem.url {
            self.bag = self.playerView.setVideo(url: url)
                .filter { $0 != nil }
                .map { $0! }
                .sink(onNext: { [weak self] duration in
                    guard let self else { return }
                    videoSliderView.set(duration: duration)
                    playerView.set(time: playItem.startTime)
                    if previous?.index != playItem.index
                        && !playerView.isPlaying
                        && needsPlay {
                        playerView.togglePlay()
                        playerContainer.uiIsVisible = false
                    }
                })
        }
    }

    private func change(enabled: Bool, view: UIView) {
        view.isUserInteractionEnabled = enabled
        view.alpha = enabled ? 1 : 0.5
    }

    private func setLoader(visible: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.loaderContainer.alpha = visible ? 1 : 0
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .from(mask: orientation)
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    // MARK: - Actions

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { [weak self] _ in
            guard let self else { return }
            if needsClose {
                needsClose = false
                viewModel.back()
            }
        })
    }

    @IBAction func closeAction(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.viewModel.back()
        } else {
            if needsClose { return }
            if orientation == .portrait {
                self.viewModel.back()
            } else {
                self.orientation = .portrait
                if UIScreen.main.interfaceOrientation == .portrait {
                    self.viewModel.back()
                } else {
                    self.needsClose = true
                    updateOrientation()
                }
            }
        }
    }

    private func updateOrientation() {
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            if orientation != .all {
                let value = UIInterfaceOrientation.from(mask: orientation)
                UIDevice.current.setValue(value.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }

    @IBAction func playPauseAction(_ sender: Any) {
        needsPlay.toggle()
        self.playerView.togglePlay()
        if self.playerView.isPlaying {
            self.playerContainer.uiIsVisible = false
        }
    }

    @IBAction func runNextItemAction() {
        viewModel.selectNext()
    }

    @IBAction func runPreviousItemAction() {
        viewModel.selectPrevious()
    }

    @IBAction func settingAction(_ sender: Any) {
        viewModel.showSettings()
    }

    @IBAction func toogleVideoGravity() {
        playerView.toogleVideoGravity()
    }

    @IBAction func togglePictureInPictureMode(_ sender: UIButton) {
        guard let pipController = pictureInPictureController else { return }
        if pipController.isPictureInPictureActive == true {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }

    @IBAction func selectVideoDidTap() {
        viewModel.selectPlayItem()
    }

    @objc private func handle(recognizer: UIPanGestureRecognizer) {
        userInteractionSubject.send()
    }
}

extension PlayerViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }
}

extension PlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        true
    }
}

private extension UIKeyCommand {
    static let inputSpace = " "
}
