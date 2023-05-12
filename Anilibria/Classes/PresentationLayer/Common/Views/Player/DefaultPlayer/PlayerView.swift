import AVKit
import Combine
import UIKit

public final class PlayerView: UIView, Player {
    private var secondsRelay: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    private var playRelay: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var statusRelay: PassthroughSubject<PlayerStatus, Never> = PassthroughSubject()
    private var bag = Set<AnyCancellable>()
    private var observer: Any?
    private var keyBag: Any?

    public private(set) var duration: Double?
    public private(set) var audioTracks: [AudioTrack] = []
    public private(set) var currentAudio: AudioTrack?
    public private(set) var subtitles: [Subtitles] = []
    public private(set) var currentSubtitles: Subtitles?

    public private(set) var isPlaying: Bool = false {
        didSet {
            self.playRelay.send(self.isPlaying)
        }
    }

    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    public var isAirplaySupported: Bool { true }

    public var playerLayer: AVPlayerLayer? {
        if let value = layer as? AVPlayerLayer {
            return value
        }
        return nil
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
        self.isPlaying = false
        self.duration = nil
        self.player?.pause()
        self.keyBag = nil
        self.statusRelay.send(.unknown)

        if let observer = self.observer {
            self.player?.removeTimeObserver(observer)
        }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)

        let statusBag = self.player?.observe(\AVPlayer.status) { [weak self] _, _ in
            if let status = self?.player?.status {
                self?.statusRelay.send(.from(status))
            }
        }

        let timeBag = self.player?.observe(\AVPlayer.timeControlStatus) { [weak self] _, _ in
            if let status = self?.player?.timeControlStatus {
                self?.statusRelay.send(.from(status))
            }
        }

        self.keyBag = [statusBag, timeBag]

        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        self.observer = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] in
            self?.secondsRelay.send($0.seconds)
        }

        return Deferred {
            AnyPublisher<Double?, Error>.just(asset.duration.seconds)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .do(onNext: { [weak self] duration in self?.duration = duration })
        .eraseToAnyPublisher()
    }

    public func set(time: Double) {
        let cmtime = CMTime(seconds: time, preferredTimescale: 1)
        self.player?.seek(to: cmtime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func set(subtitle: Subtitles) {}
    
    public func set(audio: AudioTrack) {}

    public func togglePlay() {
        self.isPlaying.toggle()
        if self.isPlaying {
            self.player?.play()
        } else {
            self.player?.pause()
        }
    }

    deinit {
        if let observer = self.observer {
            self.player?.removeTimeObserver(observer)
        }
        _ = try? AVAudioSession.sharedInstance().setActive(false)
    }
}

private extension PlayerStatus {
    static func from(_ status: AVPlayer.Status) -> PlayerStatus {
        switch status {
        case .failed:
            return .failed
        case .readyToPlay:
            return .radyToPlay
        default:
            return .unknown
        }
    }

    static func from(_ status: AVPlayer.TimeControlStatus) -> PlayerStatus {
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
