//
//  TorrentFileWriter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

class TorrentFileWriter {
    let series: Series
    let torrent: TorrentData
    let file: TorrentFile
    let filePath: URL

    private var channel: DispatchIO?
    private let queue = DispatchQueue(label: "FileWriter.queue")

    init(series: Series, torrent: TorrentData, file: TorrentFile) throws {
        self.series = series
        self.torrent = torrent
        self.file = file

        guard
            let dir = Self.getDirectoryUrl(name: "\(series.id)"),
            dir.hasFreeSpace(minCapacity: file.length)
        else { throw AppError.error(code: 1) }

        self.filePath = dir.appendingPathComponent(file.name)

        if !FileManager.default.fileExists(atPath: filePath.path) {
            if !FileManager.default.createFile(atPath: filePath.path, contents: nil) {
                throw AppError.error(code: 2)
            }
        } else {
            throw AppError.unexpectedError(message: filePath.absoluteString)
        }

        guard let cString = (filePath.path as NSString).utf8String else { throw AppError.error(code: 4) }

        self.channel = DispatchIO(type: .random, path: cString, oflag: O_WRONLY, mode: .zero, queue: queue) { [weak self] error in
            if error == 0 {
                self?.channel = nil
            }
        }
        self.channel?.setLimit(lowWater: .max)
    }

    func write(piece: PieceWork) {
        let bounds = torrent.calculateBoundsForPiece(index: piece.index)
        piece.buffer.withUnsafeBytes {
            self.channel?.write(offset: off_t(bounds.begin), data: DispatchData(bytes: $0), queue: queue, ioHandler: { done, _, error in
                print("WRITE PIECE \(piece.index): Done - \(done) + \(error)")
            })
        }
    }

    private static func getDirectoryUrl(name: String) -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let torrentsFolder = directory.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: torrentsFolder.path) {
            return torrentsFolder
        }

        do {
            try FileManager.default.createDirectory(atPath: torrentsFolder.path, withIntermediateDirectories: true, attributes: nil)
            return torrentsFolder
        } catch { }
        return nil
    }

    deinit {
        self.channel?.close()
    }
}
