//
//  WorkQueue.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class WorkQueue {
    private var pieces: [PieceWork] = []
    private let lock = NSRecursiveLock()
    private var inProgressCount: Int = 0
    let indexes: [Int]

    private let resultsSubject = PassthroughSubject<PieceWork, Never>()
    private let pieceReturnedSubject = PassthroughSubject<Void, Never>()

    var results: AnyPublisher<PieceWork, Never> {
        resultsSubject.eraseToAnyPublisher()
    }

    var pieceReturned: AnyPublisher<Void, Never> {
        pieceReturnedSubject.eraseToAnyPublisher()
    }

    let workCount: Int

    init(pieces: [PieceWork]) {
        self.pieces = pieces
        self.workCount = pieces.count
        self.indexes = pieces.map { $0.index }
    }

    func next() -> PieceWork? {
        lock.sync {
            if pieces.isEmpty { return nil }
            inProgressCount += 1
            return pieces.removeFirst()
        }
    }

    func exchange(_ item: PieceWork) -> PieceWork? {
        lock.sync {
            if pieces.isEmpty {
                inProgressCount -= 1
                pieces.insert(item, at: 0)
                pieceReturnedSubject.send()
                return nil
            }
            let nextItem = pieces.removeFirst()
            pieces.insert(item, at: 0)
            pieceReturnedSubject.send()
            return nextItem
        }
    }

    func insert(_ item: PieceWork) {
        lock.sync {
            inProgressCount -= 1
            pieces.insert(item, at: 0)
            pieceReturnedSubject.send()
        }
    }

    func set(result: PieceWork) {
        lock.sync {
            inProgressCount -= 1
            resultsSubject.send(result)
        }
    }

    func getInProgressCount() -> Int {
        lock.sync {
            return inProgressCount
        }
    }

    func getLeftCount() -> Int {
        lock.sync {
            pieces.count
        }
    }
}
