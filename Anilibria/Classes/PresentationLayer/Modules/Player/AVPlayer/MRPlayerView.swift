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

    private let airplayView = AVRoutePickerView()
    private var pictureInPictureController: AVPictureInPictureController?
    private let timeFormatter = FormatterFactory.time.create()
    private var canUpdateTime: Bool = true
    private var playlist: [PlaylistItem] = []
    private var currentIndex: Int = 0
    private var currentTime: Double = 0
    private var bag: AnyCancellable?
    private var pipObservation: Any?

    private var currentQuality: VideoQuality?
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
    var playerView: (any Player)!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let layer = playerView.playerLayer, AVPictureInPictureController.isPictureInPictureSupported() {
            pipButton.isHidden = false
            pictureInPictureController = AVPictureInPictureController(playerLayer: layer)

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

    private func setupAirPlay() {
        if playerView.isAirplaySupported {
            airplayView.tintColor = .white
            container.addSubview(airplayView)
            airplayView.constraintEdgesToSuperview()
        } else {
            container.isHidden = true
        }
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
        if let canSkip = currentListItem?.skips?.canSkip(
            time: time,
            length: skipButtonShowingSeconds
        ), canSkip {
            skipContainer.isHidden = false
        } else {
            skipContainer.isHidden = true
        }
    }

    private func saveState() {
        self.handler.save(quality: currentQuality,
                          id: playlist[currentIndex].id,
                          time: currentTime)
    }

    private func set(playItem index: Int, seek time: Double, preffered: PrefferedSettings? = nil) {
        self.clearLabels()
        self.currentIndex = index
        self.currentTime = time
        
        if preffered != nil {
            self.currentQuality = preffered?.quality
        }
        
        let item = self.playlist[index]
        let qualities = item.supportedQualities()
        guard let bestQuality = qualities.first else {
            return
        }
        
        var quality = self.currentQuality ?? bestQuality
        if qualities.contains(quality) == false {
            self.currentQuality = bestQuality
            quality = bestQuality
        }
        if let url = item.video[quality] {
            self.bag = self.playerView.setVideo(url: url)
                .filter { $0 != nil }
                .map { $0! }
                .sink(onNext: { [weak self] duration in
                    guard let self = self else { return }
                    self.videoSliderView.minimumValue = Float(0)
                    self.videoSliderView.maximumValue = Float(duration)
                    if duration == 0 {
                        self.clearLabels()
                    } else {
                        self.updateLabels()
                    }
                    self.playerView.set(time: time)
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
            let skips = currentListItem.skips,
            let endTime = skips.upperBound(time: currentTime),
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
             preffered: PrefferedSettings) {
        self.titleLabel.text = name
        self.playlist = playlist

        self.switcherView.isHidden = playlist.count < 2
        self.switcherView.set(items: self.playlist,
                              index: playItemIndex,
                              title: { $0.title })
        self.switcherView.getSelectedSequence()
            .do(onNext: { [weak self] _ in
                self?.clearLabels()
                self?.setLoader(visible: true)
            })
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink(onNext: { [weak self] index in
                var seekTime = 0.0
                if index == playItemIndex {
                    seekTime = time
                }
                self?.set(playItem: index, seek: seekTime, preffered: preffered)
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
