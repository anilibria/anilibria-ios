//
//  WorkQueueRepository.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.12.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentWork: Codable {
    let queue: WorkQueue
    let fileInfo: SeriesFile
    let date: Date
}

class WorkQueueRepository {
    private let fileExtension = "work"

    func getWork(for series: SeriesFile) -> WorkQueue {
        let path = series.filePath.appendingPathExtension(fileExtension)
        if let item = decode(url: path) {
            return item.queue
        }

        var pieces: [Int: PieceWork] = [:]
        series.torrentFile.position.boundsRange.forEach { index in
            let hash = series.torrent.pieceHashes[index]
            let size = series.torrent.calculatePieceSize(index: index, file: series.torrentFile)
            pieces[index] = PieceWork(index: index, hash: hash, length: size)
        }

        return WorkQueue(pieces: pieces)
    }

    func update(work: WorkQueue, for series: SeriesFile) throws {
        let path = series.filePath.appendingPathExtension(fileExtension)
        let data = try JSONEncoder().encode(TorrentWork(queue: work, fileInfo: series, date: Date()))
        try data.write(to: path, options: .atomic)
    }

    func remove(work: WorkQueue, for series: SeriesFile) throws {
        let path = series.filePath.appendingPathExtension(fileExtension)
        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }
    }

    func getIncompleteWorkItems() -> [TorrentWork] {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        let url = directory.appendingPathComponent(Constants.torrentsFolderName)

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsHiddenFiles]
        ) else {
            return []
        }

        var items = [TorrentWork]()

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == fileExtension, let item = decode(url: fileURL) {
                items.append(item)
            }
        }
        return items
    }

    private func decode(url: URL) -> TorrentWork? {
        if let data = try? Data(contentsOf: url), 
           let item = try? JSONDecoder().decode(TorrentWork.self, from: data) {
            return item
        }
        return nil
    }
}
