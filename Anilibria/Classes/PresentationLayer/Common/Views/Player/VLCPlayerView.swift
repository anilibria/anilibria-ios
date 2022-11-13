//
//  VLCPlayerView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 12.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import MobileVLCKit
import Combine
import AVKit

public final class VLCPlayerView: UIView, Player {
    private var secondsRelay: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    private var playRelay: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var statusRelay: PassthroughSubject<PlayerStatus, Never> = PassthroughSubject()
    private var bag = Set<AnyCancellable>()
    private var observer: Any?
    private var keyBag: Any?

    public private(set) var duration: Double?

    public private(set) var isPlaying: Bool = false {
        didSet {
            if self.isPlaying != oldValue {
                self.playRelay.send(self.isPlaying)
            }
        }
    }

    public var isAirplaySupported: Bool { false }
    public var playerLayer: AVPlayerLayer? { nil }

    private var player: VLCMediaPlayer = VLCMediaPlayer(library: VLCLibrary.shared())

    private let renderView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        setupPlayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayer() {
        isUserInteractionEnabled = false
        addSubview(renderView)
        renderView.constraintEdgesToSuperview()
        player.drawable = renderView

        player.publisher(for: \.state).sink { [weak self] _ in
            self?.updateStatus()
        }.store(in: &bag)

        player.publisher(for: \.time).sink { [weak self] time in
            if let milliseconds = time.value?.doubleValue {
                let seconds = milliseconds / 1000.0
                self?.secondsRelay.send(seconds)
            }
        }.store(in: &bag)
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
        self.keyBag = nil
        self.statusRelay.send(.unknown)

        let media = VLCMedia(url: url)
        player.media = media
        player.play()
        player.pause()
        player.time = VLCTime(int: 0)

        return Deferred { [player] in
            media.lengthWait(until: Date() + 1.minutes)
            media.parse(timeout: 0)
            let seconds = media.length.value.map { $0.doubleValue / 1000 }
            print("PLAYER: - audioTrackNames: \(player.audioTrackNames)")
            print("PLAYER: - videoSubTitlesNames: \(player.videoSubTitlesNames)")
            player.currentAudioTrackIndex = player.audioTrackIndexes.last as? Int32 ?? -1
            player.currentVideoSubTitleIndex = player.videoSubTitlesIndexes.last as? Int32 ?? -1
            return AnyPublisher<Double?, Error>.just(seconds)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .do(onNext: { [weak self] duration in
            self?.duration = duration
            self?.statusRelay.send(.radyToPlay)
        })
        .eraseToAnyPublisher()
    }

    public func set(time: Double) {
        if player.isSeekable == true {
            let milliseconds = time * 1000 as NSNumber
            player.time = VLCTime(number: milliseconds)
        }
    }

    public func togglePlay() {
        if player.isPlaying {
            player.pause()
            self.isPlaying = false
        } else {
            player.play()
            self.isPlaying = true
        }
    }

    deinit {
        _ = try? AVAudioSession.sharedInstance().setActive(false)
    }

    private func updateStatus() {
        switch player.state {
        case .error:
            statusRelay.send(.failed)
        case .paused:
            statusRelay.send(.pause)
        case .playing:
            statusRelay.send(.playing)
        case .buffering, .opening, .esAdded:
            break //  statusRelay.send(.waitingToPlay)
        default:
           break // statusRelay.send(.unknown)
        }
    }
}
