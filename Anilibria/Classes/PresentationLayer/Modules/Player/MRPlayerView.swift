import Combine
import UIKit
import AVKit

// MARK: - View Controller

final class PlayerViewController: BaseViewController {
    @IBOutlet var hidableViews: [UIView]!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pipButton: UIButton!
    @IBOutlet var playPauseButton: RippleButton!
    @IBOutlet var playPauseIconView: UIImageView!
    @IBOutlet var switcherView: SwitcherView!
    @IBOutlet var timeLeftLabel: UILabel!
    @IBOutlet var elapsedTimeLabel: UILabel!
    @IBOutlet var videoSliderView: TouchableSlider!
    @IBOutlet var playerContainer: UIView!
    @IBOutlet var loaderContainer: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var rewindButtons: [RewindView] = []
    @IBOutlet var skipContainer: UIView!
    @IBOutlet var skipButtonLabel: UILabel!
    @IBOutlet var topShadowView: ShadowView!
    @IBOutlet var bottomShadowView: ShadowView!

    private let playerView = PlayerView()
    private let airplayView = AVRoutePickerView()
    private var pictureInPictureController: AVPictureInPictureController?
    private let timeFormatter = FormatterFactory.time.create()
    private var canUpdateTime: Bool = true
    private var playlist: [PlaylistItem] = []
    private var currentIndex: Int = 0
    private var currentTime: Double = 0
    private var bag: AnyCancellable?
    private var pipObservation: Any?

    private var currentQuality: VideoQuality = .fullHd
    private var orientation: UIInterfaceOrientationMask = .all

    private let rewindTimes: [Double] = [-15, -5, 5, 15]

    private var uiIsVisible: Bool = true {
        didSet {
            self.setUI(visible: self.uiIsVisible)
        }
    }
    
    private let skipButtonShowingSeconds = 10
    
    private var currentListItem: PlaylistItem? {
        playlist[safe: currentIndex]
    }

    var handler: PlayerEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.handler.didLoad()
        self.addTermenateAppObserver()
        self.setupPlayer()
        self.setupSwitcher()
        self.setupRewind()
        self.setupAirPlay()
        self.setupPictureInPicture()
        self.videoSliderView.setThumbImage(UIImage(resource: .iconCircle), for: .normal)

        let font: UIFont = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        self.timeLeftLabel.font = font
        self.elapsedTimeLabel.font = font
        self.clearLabels()

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

    override func setupStrings() {
        super.setupStrings()
        skipButtonLabel.text = L10n.Buttons.skip
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveState()
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
        let back = UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(self.rewindBack))
        let forward = UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(self.rewindForward))
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            back.wantsPriorityOverSystemBehavior = true
            forward.wantsPriorityOverSystemBehavior = true
        }

        return [
            UIKeyCommand(input: UIKeyCommand.inputSpace, modifierFlags: [], action: #selector(self.playPauseAction(_:))),
            back,
            forward,
        ]
    }

    private func setupSwitcher() {
        self.switcherView.didTapTitle { [weak self] in
            self?.handler.select(playItemIndex: $0)
        }
    }

    private func setupPlayer() {
        self.playerContainer.addSubview(self.playerView)
        self.playerView.constraintEdgesToSuperview()

        self.playerView.getCurrentTime()
            .filter { [weak self] _ in
                self?.canUpdateTime ?? false
            }
            .sink(onNext: { [weak self] time in
                let value = Float(time)
                self?.currentTime = time
                self?.videoSliderView.setValue(value, animated: true)
                self?.updateLabels()
                self?.updateSkipButton(time: Int(time))
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
                case .pause:
                    break
                default:
                    self?.canUpdateTime = true
                    self?.setLoader(visible: false)
                }
            })
            .store(in: &subscribers)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.playerTapped))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.playerContainer.addGestureRecognizer(tap)
    }

    private func setupRewind() {
        rewindButtons.enumerated().forEach { offset, view in
            view.set(time: rewindTimes[offset])
            view.setDidTap { [weak self] in self?.apply(rewind: $0) }
        }
    }

    func setupPictureInPicture() {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipButton.isHidden = false
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerView.playerLayer)
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
        guard playerView.duration != nil else { return }
        let newTime = videoSliderView.value + Float(time)

        let playing = playerView.isPlaying
        if playing { playerView.togglePlay() }

        sliderTouchDown(self)
        videoSliderView.setValue(newTime, animated: true)
        sliderValueChanged(self)
        sliderTouchUp(self)

        if playing { playerView.togglePlay() }
        updateSkipButton(time: Int(newTime))
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

    private func clearLabels() {
        self.timeLeftLabel.text = "--:--"
        self.elapsedTimeLabel.text = "--:--"
    }

    private func updateLabels() {
        let value = self.videoSliderView.value
        self.timeLeftLabel.text = self.timeFormatter.string(from: value)
        let max = self.videoSliderView.maximumValue
        let elapsed = self.timeFormatter.string(from: max - value) ?? ""
        self.elapsedTimeLabel.text = "-\(elapsed)"
    }
    
    private func updateSkipButton(time: Int) {
        if let canSkip = currentListItem?.skips.canSkip(
            time: time,
            length: skipButtonShowingSeconds
        ), canSkip {
            skipContainer.isHidden = false
        } else {
            skipContainer.isHidden = true
        }
    }

    private func saveState() {
        self.handler.save(quality: self.currentQuality,
                          number: self.currentIndex,
                          time: self.currentTime)
    }

    private func set(playItem index: Int, seek time: Double) {
        self.clearLabels()
        self.currentIndex = index
        self.currentTime = time
        let item = self.playlist[index]
        let qualities = item.supportedQualities()
        guard let bestQuality = qualities.first else {
            return
        }
        if qualities.contains(self.currentQuality) == false {
            self.currentQuality = bestQuality
        }
        if let url = item.video[self.currentQuality] {
            self.bag = self.playerView.setVideo(url: url)
                .filter { $0 != nil }
                .map { $0! }
                .sink(onNext: { [weak self] duration in
                    self?.videoSliderView.minimumValue = Float(0)
                    self?.videoSliderView.maximumValue = Float(duration)
                    if duration == 0 {
                        self?.clearLabels()
                    } else {
                        self?.updateLabels()
                    }
                    self?.playerView.set(time: time)
                })
        }
    }

    private func setUI(visible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.hidableViews.forEach {
                $0.alpha = visible ? 1 : 0
            }
        }
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
        self.saveState()
        sleep(2) // this used for to give time for save async data
    }

    @objc func playerTapped() {
        self.uiIsVisible.toggle()
    }

    @IBAction func closeAction(_ sender: Any) {
        self.orientation = .portrait
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
        self.handler.back()
    }

    @IBAction func downloadAction(_ sender: Any) {}

    @IBAction func playPauseAction(_ sender: Any) {
        self.playerView.togglePlay()
        if self.playerView.isPlaying {
            self.uiIsVisible = false
        }
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        self.updateLabels()
    }

    @IBAction func sliderTouchUp(_ sender: Any) {
        let time = self.videoSliderView.value
        self.playerView.set(time: Double(time))
    }

    @IBAction func sliderTouchDown(_ sender: Any) {
        self.canUpdateTime = false
    }

    @IBAction func settingAction(_ sender: Any) {
        let index = self.switcherView.currentIndex
        let item = self.playlist[index]
        self.handler.settings(quality: self.currentQuality, for: item)
    }

    @IBAction func togglePictureInPictureMode(_ sender: UIButton) {
        guard let pipController = pictureInPictureController else { return }
        if pipController.isPictureInPictureActive == true {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }
    
    @IBAction func skipDidTap() {
        let currentTime = Int(videoSliderView.value)
        guard
            let currentListItem = currentListItem,
            let endTime = currentListItem.skips.upperBound(time: currentTime),
            endTime > currentTime
        else {
            return
        }
        
        self.apply(rewind: Double(endTime - currentTime))
    }
}

extension PlayerViewController: PlayerViewBehavior {
    func set(name: String,
             playlist: [PlaylistItem],
             playItemIndex: Int,
             time: Double,
             preffered quality: VideoQuality) {
        self.titleLabel.text = name
        self.playlist = playlist

        self.switcherView.set(items: self.playlist,
                              index: playItemIndex,
                              title: { $0.name })
        self.switcherView.getSelectedSequence()
            .do(onNext: { [weak self] _ in
                self?.clearLabels()
                self?.setLoader(visible: true)
            })
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink(onNext: { [weak self] index in
                self?.currentQuality = quality
                var seekTime = 0.0
                if index == playItemIndex {
                    seekTime = time
                }
                self?.set(playItem: index, seek: seekTime)
            })
            .store(in: &subscribers)
    }

    func set(playItemIndex: Int) {
        self.switcherView.set(current: playItemIndex)
    }

    func set(quality: VideoQuality) {
        let index = self.switcherView.currentIndex
        self.currentQuality = quality
        self.set(playItem: index, seek: self.currentTime)
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

public final class TouchableSlider: UISlider {
    private var firstLocation: CGPoint?

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }

        self.firstLocation = touch.location(in: self)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)

        if floor(location.x) != floor(self.firstLocation?.x ?? 0) {
            return
        }

        let thumbWidth = self.currentThumbImage?.size.width ?? 0
        let percent = Float((location.x - thumbWidth/2) / (self.frame.width - thumbWidth))
        self.setValue(percent * self.maximumValue, animated: false)
        self.sendActions(for: .touchDown)
        self.sendActions(for: .touchUpInside)
    }
}

final class RewindView: CircleView {
    @IBOutlet var titleLabel: UILabel!
    private var tapHandler: Action<Double>?

    private var time: Double = 0

    func set(time: Double) {
        self.time = time
        self.titleLabel.text = "\(Int(abs(time)))"
    }

    func setDidTap(_ action: Action<Double>?) {
        self.tapHandler = action
    }

    @IBAction func tapAction(_ sender: Any) {
        self.tapHandler?(time)
    }
}


private extension UIKeyCommand {
    static let inputSpace = " "
}

private extension PlaylistItem {
    var name: String {
        if let ordinal  {
            return "\(NSNumber(value: ordinal))"
        }
        return title
    }
}
