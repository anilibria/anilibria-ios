//
//  PieceProgress.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

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
        if isChocked { return }
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
        backlog -= 1
        piece.downloaded += size
        let speed = Int64(Double(size) / abs(startTime.timeIntervalSinceNow)) // bytes per second

        if speed / 1024 < 10 {
            strike += 1
        }

        if isCompleted {
            downloadingCompleted?(piece)
        } else if strike > maxStrikeCount {
            self.timeoutHandler?()
        } else {
            run(isChocked)
        }
    }
}
