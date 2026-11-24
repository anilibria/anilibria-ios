import AVKit
import Combine
import UIKit

public final class DefaultPlayerView: UIView, Player {
    private var secondsRelay: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    private var bufferingRelay: CurrentValueSubject<ClosedRange<Double>?, Never> = CurrentValueSubject(nil)
    private var playRelay: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var statusRelay: PassthroughSubject<PlayerStatus, Never> = PassthroughSubject()
    private var isSeeking: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var seekCompletion: (() -> Void)?
    private var bag = Set<AnyCancellable>()
    private var observer: Any?
    private var actionHolder: ActionHolder?
    private var playbackRate: Double = 1

    public private(set) var duration: Double?

    public private(set) var isPlaying: Bool = false {
        didSet {
            self.playRelay.send(self.isPlaying)
        }
    }

    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    public var playerLayer: AVPlayerLayer? {
        layer as? AVPlayerLayer
    }

    private var player: AVPlayer? {
        get {
            return self.playerLayer?.player
        }
        set {
            self.playerLayer?.player = newValue
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func getCurrentTime() -> AnyPublisher<Double, Never> {
        return self.secondsRelay
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func getBufferTime() -> AnyPublisher<ClosedRange<Double>?, Never> {
        return self.bufferingRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getPlayChanges() -> AnyPublisher<Bool, Never> {
        return self.playRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getStatusSequence() -> AnyPublisher<PlayerStatus, Never> {
        return self.statusRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func setVideo(url: URL) -> AnyPublisher<Double?, Error> {
        self.bag.removeAll()
        self.isSeeking.send(false)
        self.isPlaying = false
        self.duration = nil
        self.player?.pause()
        self.actionHolder = nil
        self.removeTimeObserver()
        self.statusRelay.send(.unknown)

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)

        setupStateObserving()
        observeTime()
        observeBuffer(for: item)
        return Deferred {
            Future { promise in
                asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                    promise(.success(asset.duration.seconds))
                }
            }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .do(onNext: { [weak self] duration in self?.duration = duration })
        .eraseToAnyPublisher()
    }

    public func set(time: Double) {
        isSeeking.send(true)
        removeTimeObserver()
        let action = ActionHolder { [weak self] in
            self?.isSeeking.send(false)
            self?.observeTime()
        }
        self.actionHolder = action
        let cmtime = CMTime(seconds: time, preferredTimescale: 1)
        self.player?.seek(to: cmtime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak action] completed in
            action?.run()
        }
    }

    public func set(rate: Double) {
        playbackRate = rate
        if isPlaying {
            player?.rate = Float(rate)
        }
    }

    public func togglePlay() {
        self.isPlaying.toggle()
        if self.isPlaying {
            self.player?.play()
            self.player?.rate = Float(playbackRate)
        } else {
            self.player?.pause()
        }
    }

    public func toogleVideoGravity() {
        switch playerLayer?.videoGravity {
        case .resizeAspect:
            playerLayer?.videoGravity = .resizeAspectFill
        case .resizeAspectFill:
            playerLayer?.videoGravity = .resize
        default:
            playerLayer?.videoGravity = .resizeAspect
        }
    }

    private func observeBuffer(for item: AVPlayerItem) {
        item.publisher(for: \.loadedTimeRanges).sink { [weak self] renges in
            if let range = renges.first as? CMTimeRange {
                self?.bufferingRelay.send(range.start.seconds...range.end.seconds)
            } else {
                self?.bufferingRelay.send(nil)
            }
        }.store(in: &bag)
    }

    private func setupStateObserving() {
        guard let player else { return }
        Publishers.CombineLatest3(
            player.publisher(for: \.status),
            player.publisher(for: \.timeControlStatus),
            isSeeking.removeDuplicates()
        ).sink { [weak self] status, timeControlStatus, isSeeking in
            switch status {
            case .readyToPlay:
                if isSeeking {
                    self?.statusRelay.send(.waitingToPlay)
                } else {
                    self?.statusRelay.send(.convert(timeControlStatus))
                }
            case .failed:
                self?.statusRelay.send(.failed)
            default:
                self?.statusRelay.send(.unknown)
            }
        }.store(in: &bag)
    }

    private func observeTime() {
        removeTimeObserver()
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        if let seconds = player?.currentTime().seconds {
            secondsRelay.send(seconds)
        }
        self.observer = self.player?
            .addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] in
                self?.secondsRelay.send($0.seconds)
            }
    }

    private func removeTimeObserver() {
        if let observer {
            self.observer = nil
            self.player?.removeTimeObserver(observer)
        }
    }

    deinit {
        self.removeTimeObserver()
        _ = try? AVAudioSession.sharedInstance().setActive(false)
    }
}

private extension PlayerStatus {
    static func convert(_ status: AVPlayer.TimeControlStatus) -> PlayerStatus {
        switch status {
        case .paused:
            return .pause
        case .playing:
            return .playing
        case .waitingToPlayAtSpecifiedRate:
            return .waitingToPlay
        default:
            return .unknown
        }
    }
}

private extension DefaultPlayerView {
    class ActionHolder {
        let run: (() -> Void)
        init(run: @escaping () -> Void) {
            self.run = run
        }
    }
}
