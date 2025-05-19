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
    private var pipObservation: Any?

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
        self.addTermenateAppObserver()
        self.setupPlayer()
        self.setupAirPlay()
        self.setupPictureInPicture()

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

        #if targetEnvironment(macCatalyst)
        let window = UIApplication.getWindow()
        window?.windowScene?.sizeRestrictions?.minimumSize = Sizes.minSize
        window?.windowScene?.sizeRestrictions?.maximumSize = Sizes.maxSize

        MacOSHelper.shared.fullscreenButtonEnabled = true
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.save()
        #if targetEnvironment(macCatalyst)
        let window = UIApplication.getWindow()
        window?.windowScene?.sizeRestrictions?.minimumSize = Sizes.minSize
        window?.windowScene?.sizeRestrictions?.maximumSize = Sizes.minSize

        MacOSHelper.shared.toggleFullScreen()
        MacOSHelper.shared.fullscreenButtonEnabled = false
        #endif
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

        if #available(iOS 15.0, macCatalyst 15.0, *) {
            back.wantsPriorityOverSystemBehavior = true
            forward.wantsPriorityOverSystemBehavior = true
        }

        return [playPause, back, forward]
    }

    private func setup() {
        skipContainer.configure(with: viewModel.skipViewModel)
        viewModel.skipViewModel.skipHandler = { [weak self] time in
            self?.apply(rewind: time)
        }

        titleLabel.text = viewModel.seriesName

        videoSliderView.set(duration: 0)
        setLoader(visible: true)

        viewModel.$orientation.sink { [weak self] value in
            self?.orientation = value.mask
            self?.updateOrientation()
        }.store(in: &subscribers)

        viewModel.$playItem.compactMap { $0 }
            .sink { [weak self] item in
                self?.set(playItem: item)
            }.store(in: &subscribers)

        viewModel.$playbackRate
            .sink { [weak self] rate in
                self?.playerView.set(rate: rate)
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
                let image = UIImage(resource: value ? .iconPause : .iconPlay)
                self?.playPauseIconView.templateImage = image
            })
            .store(in: &subscribers)

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

    private func setupAirPlay() {
        airplayView.tintColor = .white
        container.addSubview(airplayView)
        airplayView.constraintEdgesToSuperview()
    }

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

    private func set(playItem: PlayItem) {
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
                    playerView.set(time: playItem.time)
                    if !playerView.isPlaying {
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

    override func appWillTerminate() {
        super.appWillTerminate()
        viewModel.save()
        sleep(2) // this used for to give time for save async data
    }

    @IBAction func closeAction(_ sender: Any) {
        self.orientation = .portrait
        updateOrientation()
        self.viewModel.back()
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

    @IBAction func downloadAction(_ sender: Any) {}

    @IBAction func playPauseAction(_ sender: Any) {
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
}

extension PlayerViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }
}


private extension UIKeyCommand {
    static let inputSpace = " "
}
