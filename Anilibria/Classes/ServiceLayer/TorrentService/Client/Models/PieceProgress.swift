//
//  PieceProgress.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class PieceProgress {
    let formatter = ByteCountFormatter()
    private let maxBacklog = 5
    let maxBlockSize = 16384
    let maxStrikeCount = 10

    let piece: PieceWork
    var requested: Int = 0
    var backlog: Int = 0
    private var strike = 0
    private var startTime: Date = Date()

    private var sendHandler: ((PeerMessage) -> Void)?
    private var downloadingCompleted: ((PieceWork) -> Void)?
    private var timeoutHandler: (() -> Void)?
    private var timerSubscriber: AnyCancellable?

    var isCompleted: Bool {
        piece.downloaded >= piece.length
    }

    var isWorking: Bool {
        backlog > 0
    }

    init(piece: PieceWork) {
        self.piece = piece
        self.requested = piece.downloaded
    }

    func run(_ isChocked: Bool) {
        setTimeout()
        startTime = Date()
        while backlog < maxBacklog && requested < piece.length {
            var blockSize = maxBlockSize

            if piece.length - requested < blockSize {
                blockSize = piece.length - requested
            }

            sendHandler?(.makeRequest(index: piece.index, begin: requested, length: blockSize))
            backlog += 1
            requested += blockSize
        }
    }

    func setSender(_ action: ((PeerMessage) -> Void)?) {
        sendHandler = action
    }

    func didComplete(_ action: ((PieceWork) -> Void)?) {
        downloadingCompleted = action
    }

    func setTimeout(_ action: (() -> Void)?) {
        timeoutHandler = action
    }

    func update(with message: PeerMessage, isChocked: Bool) {
        guard let size = try? message.parsePiece(index: piece.index, buffer: &piece.buffer) else { return }
        timerSubscriber = nil
        backlog -= 1
        piece.downloaded += size
        let speed = Int64(Double(size) / abs(startTime.timeIntervalSinceNow)) // bytes per second
        let formattedSpeed = formatter.string(fromByteCount: speed)
        let progress = round(Double(piece.downloaded) / Double(piece.length) * 10000) / 100
        print("=@= [\(self.piece)] - progress: \(progress)% speed: \(formattedSpeed)")

        if speed / 1024 < 10 {
            strike += 1
        }

        if isCompleted {
            downloadingCompleted?(piece)
        } else if strike > maxStrikeCount {
            print("== [\(self.piece)] - strike: receive timeout")
            self.timeoutHandler?()
        } else {
            run(isChocked)
        }
    }
    
    private func setTimeout() {
        if timerSubscriber == nil {
            timerSubscriber = Timer.publish(every: 10, on: .current, in: .common)
                .autoconnect()
                .first()
                .sink(receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    print("== [\(self.piece)] - timer: receive timeout")
                    self.timeoutHandler?()
                })
        }
    }
}
