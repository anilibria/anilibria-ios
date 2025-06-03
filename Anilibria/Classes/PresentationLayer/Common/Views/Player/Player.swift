//
//  Player.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.04.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import AVKit
import Combine
import UIKit

public protocol Player: UIView {
    var playerLayer: AVPlayerLayer? { get }
    var duration: Double? { get }
    var isPlaying: Bool { get }
    func setVideo(url: URL) -> AnyPublisher<Double?, Error>
    func set(time: Double)
    func set(rate: Double)
    func togglePlay()
    func toogleVideoGravity()
    func getCurrentTime() -> AnyPublisher<Double, Never>
    func getPlayChanges() -> AnyPublisher<Bool, Never>
    func getStatusSequence() -> AnyPublisher<PlayerStatus, Never>
    func getBufferTime() -> AnyPublisher<ClosedRange<Double>?, Never>
}
