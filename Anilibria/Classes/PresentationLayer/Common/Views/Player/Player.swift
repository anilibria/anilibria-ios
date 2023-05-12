//
//  Player.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import AVKit
import Combine
import UIKit

public protocol Player: UIView {
    var playerLayer: AVPlayerLayer? { get }
    var isAirplaySupported: Bool { get }
    var duration: Double? { get }
    var audioTracks: [AudioTrack] { get }
    var currentAudio: AudioTrack? { get }
    var subtitles: [Subtitles] { get }
    var currentSubtitles: Subtitles? { get }
    var isPlaying: Bool { get }
    func setVideo(url: URL) -> AnyPublisher<Double?, Error>
    func set(time: Double)
    func set(subtitle: Subtitles)
    func set(audio: AudioTrack)
    func togglePlay()
    func getCurrentTime() -> AnyPublisher<Double, Never>
    func getPlayChanges() -> AnyPublisher<Bool, Never>
    func getStatusSequence() -> AnyPublisher<PlayerStatus, Never>
}
