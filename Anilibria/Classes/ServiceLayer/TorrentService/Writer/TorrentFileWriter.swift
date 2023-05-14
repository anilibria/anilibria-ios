//
//  TorrentFileWriter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class SeriesFile: Hashable {
    let series: Series
    let filePath: URL
    let torrentFile: TorrentFile
    let torrent: TorrentData

    enum Status {
        case ready
        case lackOfData
        case notExists
    }

    private(set) var status: Status = .notExists

    var fileSize: Int = 0 {
        didSet {
            updateStatus()
        }
    }

    init(series: Series, torrent: TorrentData, file: TorrentFile) throws {
        self.series = series
        self.torrent = torrent
        self.torrentFile = file

        guard
            let dir = Self.getDirectoryUrl(name: "\(series.id)"),
            dir.hasFreeSpace(minCapacity: file.length)
        else { throw AppError.error(code: 1) }

        self.filePath = dir.appendingPathComponent(file.name)

        if FileManager.default.fileExists(atPath: filePath.path) {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath.path)
            fileSize = (attributes[FileAttributeKey.size] as? NSNumber)?.intValue ?? 0
            updateStatus()
        }
    }

    private func updateStatus() {
        if fileSize == torrentFile.length {
            status = .ready
        } else {
            status = .lackOfData
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(torrentFile)
    }

    private static func getDirectoryUrl(name: String) -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let targetFolder = directory
            .appendingPathComponent(Constants.torrentsFolderName)
            .appendingPathComponent(name)

        if FileManager.default.fileExists(atPath: targetFolder.path) {
            return targetFolder
        }

        do {
            try FileManager.default.createDirectory(atPath: targetFolder.path, withIntermediateDirectories: true, attributes: nil)
            return targetFolder
        } catch { }
        return nil
    }

    static func == (lhs: SeriesFile, rhs: SeriesFile) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class TorrentFileWriter {
    private let series: SeriesFile
    private var channel: DispatchIO?
    private let queue = DispatchQueue(label: "FileWriter.queue")
    private var workSubscriber: AnyCancellable?

    init(series: SeriesFile) throws {
        self.series = series

        if series.status == .notExists {
            if !FileManager.default.createFile(atPath: series.filePath.path, contents: nil) {
                throw AppError.error(code: 2)
            }
        }

        guard let cString = (series.filePath.path as NSString).utf8String else { throw AppError.error(code: 4) }

        self.channel = DispatchIO(type: .random, path: cString, oflag: O_WRONLY, mode: .zero, queue: queue) { [weak self] error in
            if error == 0 {
                self?.channel = nil
            }
        }
        self.channel?.setLimit(lowWater: .max)
    }

    func write(piece: PieceWork, completed: @escaping (Bool) -> Void) {
        let data = prepare(piece: piece)
        data.buffer.withUnsafeBytes {
            self.channel?.write(
                offset: off_t(data.offset),
                data: DispatchData(bytes: $0),
                queue: queue,
                ioHandler: { [weak self] done, _, error in
                    if !done { return }
                    if error == 0 {
                        self?.series.fileSize += data.buffer.count
                        completed(true)
                    } else {
                        completed(false)
                    }
                }
            )
        }
    }

    private func prepare(piece: PieceWork) -> (offset: Int, buffer: [UInt8]) {
        let bounds = series.torrent.calculateBoundsForPiece(index: piece.index, file: series.torrentFile)
        let offset = max(bounds.begin, 0)
        if offset == 0 {
            return (offset, Array(piece.buffer.dropFirst(series.torrentFile.position.dataInsets.begin)))
        }

        let end = bounds.end - series.torrentFile.position.dataInsets.end
        if end == series.torrentFile.length {
            return (offset, Array(piece.buffer.dropLast(series.torrentFile.position.dataInsets.end)))
        }

        return (offset, piece.buffer)
    }

    deinit {
        self.channel?.close()
    }
}
