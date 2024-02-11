//
//  WorkQueue.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

actor WorkQueueActor {
    let queue: WorkQueue
    private var resultsСontinuation: AsyncStream<PieceWork>.Continuation?

    private(set) lazy var results = AsyncStream<PieceWork> { continuation in
        resultsСontinuation = continuation
    }

    init(queue: WorkQueue) {
        self.queue = queue
    }

    func getPiece(for target: Bitfield) -> PieceWork? {
        queue.getPiece(for: target)
    }

    func insert(_ item: PieceWork) {
        queue.insert(item)
    }

    func set(result: PieceWork) {
        resultsСontinuation?.yield(result)
    }

    func setCompletedPiece(_ item: PieceWork) {
        queue.setCompletedPiece(item)
        if queue.progress.isFinished {
            resultsСontinuation?.finish()
        }
    }

    func getInProgressCount() -> Int {
        queue.getInProgressCount()
    }

    func getLeftCount() -> Int {
        queue.getLeftCount()
    }

    func getBitfield() -> Bitfield {
        queue.getBitfield()
    }

    func getProgress() -> Progress {
        queue.progress
    }

    deinit {
        print("TEST> DEINIT WorkQueueActor")
    }
}

class WorkQueue: Codable {
    private var pieces: [Int: PieceWork] = [:]
    private var inProgressPieces: Set<PieceWork> = []

    private(set) lazy var progress: Progress = Progress(totalUnitCount: Int64(workCount))

    let workCount: Int
    private var bitfield = Bitfield()

    init(pieces: [Int: PieceWork]) {
        self.pieces = pieces
        self.workCount = pieces.count
        fillBitfield()
    }

    required init(from decoder: Decoder) throws {
        self.workCount = decoder["workCount"] ?? 0
        self.pieces <- decoder["pieces"]
        if let inProgress: [PieceWork] = decoder["inProgressPieces"] {
            inProgress.forEach { self.pieces[$0.index] = $0 }
        }
        progress.completedUnitCount = Int64(workCount - pieces.count)
        fillBitfield()
    }
    
    private func fillBitfield() {
        pieces.keys.forEach {
            bitfield.setPiece(index: $0)
        }
    }

    func encode(to encoder: Encoder) throws {
        encoder.apply { container in
            container["workCount"] = workCount
            container["pieces"] = pieces
            container["inProgressPieces"] = inProgressPieces
        }
    }

    func getPiece(for target: Bitfield) -> PieceWork? {
        if pieces.isEmpty { return nil }
        if let index = bitfield.intersection(target).getFirstIndex(),
           let item = pieces[index] {
            pieces.removeValue(forKey: index)
            bitfield.removePiece(index: item.index)
            inProgressPieces.insert(item)
            return item
        }
        return nil
    }

    func insert(_ item: PieceWork) {
        inProgressPieces.remove(item)
        pieces[item.index] = item
        bitfield.setPiece(index: item.index)
    }

    func setCompletedPiece(_ item: PieceWork) {
        progress.completedUnitCount += 1
        inProgressPieces.remove(item)
    }

    func getInProgressCount() -> Int {
        inProgressPieces.count
    }

    func getLeftCount() -> Int {
        pieces.count
    }
    
    func getBitfield() -> Bitfield {
        bitfield
    }
}
