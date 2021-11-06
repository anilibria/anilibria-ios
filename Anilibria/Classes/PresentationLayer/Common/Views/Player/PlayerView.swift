import AVKit
import RxCocoa
import RxSwift
import UIKit

public final class PlayerView: UIView {
    enum Status {
        case unknown
        case failed
        case radyToPlay
        case playing
        case pause
        case waitingToPlay

        static func convert(_ status: AVPlayer.Status) -> Status {
            switch status {
            case .failed:
                return .failed
            case .readyToPlay:
                return .radyToPlay
            default:
                return .unknown
            }
        }

        static func convert(_ status: AVPlayer.TimeControlStatus) -> Status {
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

    private var secondsRelay: BehaviorSubject<Double> = BehaviorSubject(value: 0)
    private var playRelay: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private var statusRelay: PublishSubject<Status> = PublishSubject()
    private var bag: DisposeBag = DisposeBag()
    private var observer: Any?
    private var keyBag: Any?

    public private(set) var duration: Double?

    public private(set) var isPlaying: Bool = false {
        didSet {
            self.playRelay.onNext(self.isPlaying)
        }
    }

    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        if let value = layer as? AVPlayerLayer {
            return value
        }
        fatalError()
    }

    private var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getCurrentTime() -> Observable<Double> {
        return self.secondsRelay
            .asObservable()
            .distinctUntilChanged()
    }

    func getPlayChanges() -> Observable<Bool> {
        return self.playRelay
            .asObservable()
            .distinctUntilChanged()
    }

    func getStatusSequence() -> Observable<Status> {
        return self.statusRelay
            .asObservable()
            .distinctUntilChanged()
    }

    func setVideo(url: URL) -> Single<Double?> {
        self.isPlaying = false
        self.duration = nil
        self.player?.pause()
        self.keyBag = nil
        self.statusRelay.onNext(.unknown)

        if let observer = self.observer {
            self.player?.removeTimeObserver(observer)
        }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)

        let statusBag = self.player?.observe(\AVPlayer.status) { [weak self] _, _ in
            if let status = self?.player?.status {
                self?.statusRelay.onNext(Status.convert(status))
            }
        }

        let timeBag = self.player?.observe(\AVPlayer.timeControlStatus) { [weak self] _, _ in
            if let status = self?.player?.timeControlStatus {
                self?.statusRelay.onNext(Status.convert(status))
            }
        }

        self.keyBag = [statusBag, timeBag]

        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] in
            self?.secondsRelay.onNext($0.seconds)
        }

        return Single.deferred {
            .just(asset.duration.seconds)
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
        .do(onSuccess: { [weak self] duration in self?.duration = duration })
    }

    func set(time: Double) {
        let cmtime = CMTime(seconds: time, preferredTimescale: 1)
        self.player?.seek(to: cmtime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func togglePlay() {
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
