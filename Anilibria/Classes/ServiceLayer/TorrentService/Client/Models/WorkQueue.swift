//
//  WorkQueue.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class WorkQueue: Codable {
    private var pieces: [PieceWork] = []
    private var inProgressPieces: Set<PieceWork> = []
    private let lock = NSRecursiveLock()

    private let resultsSubject = PassthroughSubject<PieceWork, Never>()
    private let pieceReturnedSubject = PassthroughSubject<Void, Never>()

    var results: AnyPublisher<PieceWork, Never> {
        resultsSubject.eraseToAnyPublisher()
    }

    var pieceReturned: AnyPublisher<Void, Never> {
        pieceReturnedSubject.eraseToAnyPublisher()
    }

    private(set) lazy var progress: Progress = Progress(totalUnitCount: Int64(workCount))

    let workCount: Int
    private(set) var bitfield = Bitfield()

    init(pieces: [PieceWork]) {
        self.pieces = pieces
        self.workCount = pieces.count
        fillBitfield()
    }

    required init(from decoder: Decoder) throws {
        self.workCount = decoder["workCount"] ?? 0
        self.pieces <- decoder["pieces"]
        if let inProgress: [PieceWork] = decoder["inProgressPieces"] {
            self.pieces.insert(contentsOf: inProgress, at: 0)
        }
        progress.completedUnitCount = Int64(workCount - pieces.count)
        fillBitfield()
    }
    
    private func fillBitfield() {
        pieces.forEach {
            bitfield.setPiece(index: UInt32($0.index))
        }
    }

    func encode(to encoder: Encoder) throws {
        encoder.apply { container in
            container["workCount"] = workCount
            container["pieces"] = pieces
            container["inProgressPieces"] = inProgressPieces
        }
    }

    func next() -> PieceWork? {
        lock.sync {
            if pieces.isEmpty { return nil }
            let item = pieces.removeFirst()
            bitfield.removePiece(index: item.index)
            inProgressPieces.insert(item)
            return item
        }
    }

    func exchange(_ item: PieceWork) -> PieceWork? {
        lock.sync {
            if pieces.isEmpty {
                pieces.insert(item, at: 0)
                bitfield.setPiece(index: item.index)
                pieceReturnedSubject.send()
                return nil
            }
            let nextItem = pieces.removeFirst()
            pieces.insert(item, at: 0)
            bitfield.setPiece(index: item.index)
            bitfield.removePiece(index: nextItem.index)
            pieceReturnedSubject.send()
            return nextItem
        }
    }

    func insert(_ item: PieceWork) {
        lock.sync {
            inProgressPieces.remove(item)
            pieces.insert(item, at: 0)
            bitfield.setPiece(index: item.index)
            pieceReturnedSubject.send()
        }
    }

    func set(result: PieceWork) {
        lock.sync {
            resultsSubject.send(result)
        }
    }

    func setCompletedPiece(_ item: PieceWork) {
        lock.sync {
            progress.completedUnitCount += 1
            inProgressPieces.remove(item)
        }
    }

    func getInProgressCount() -> Int {
        lock.sync {
            return inProgressPieces.count
        }
    }

    func getLeftCount() -> Int {
        lock.sync {
            pieces.count
        }
    }
}
