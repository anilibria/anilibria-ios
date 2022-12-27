//
//  WorkQueueRepository.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.12.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

class WorkQueueRepository {
    private let fileExtension = "work"

    func getWork(for series: SeriesFile) -> WorkQueue {
        let path = series.filePath.appendingPathExtension(fileExtension)
        if let data = try? Data(contentsOf: path), let item = try? JSONDecoder().decode(WorkQueue.self, from: data) {
            return item
        }

        let pieces = series.torrentFile.position.boundsRange.map { index in
            let hash = series.torrent.pieceHashes[index]
            let size = series.torrent.calculatePieceSize(index: index, file: series.torrentFile)
            return PieceWork(index: index, hash: hash, length: size)
        }

        return WorkQueue(pieces: pieces)
    }

    func update(work: WorkQueue, for series: SeriesFile) throws {
        let path = series.filePath.appendingPathExtension(fileExtension)
        let data = try JSONEncoder().encode(work)
        try data.write(to: path, options: .atomic)
    }

    func remove(work: WorkQueue, for series: SeriesFile) throws {
        let path = series.filePath.appendingPathExtension(fileExtension)
        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }
    }
}
