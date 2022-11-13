//
//  TorrentClient.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class TorrentClient {
    let series: Series
    let torrent: TorrentData
    let peers: [Peer]
    var work: WorkQueue?

    var clients: [PeerClient] = []

    var subscribers = Set<AnyCancellable>()

    init(series: Series, torrent: TorrentData, peers: [Peer]) {
        self.series = series
        self.torrent = torrent
        self.peers = peers
    }

    var clientsCount = 0

    func download(file: TorrentFile) -> URL? {
        guard torrent.content.files.contains(file) else {
            return nil
        }

        var writer: TorrentFileWriter?

        do {
            writer = try TorrentFileWriter(series: series, torrent: torrent, file: file)
        } catch {
            if case let .unexpectedError(message) = error as? AppError {
                return URL(string: message)
            }
            return nil
        }

        guard let bounds = torrent.getPieceHashesBounds(for: file) else {
            return nil
        }

        let pieces = (bounds.begin...bounds.end).map { index in
            let hash = torrent.pieceHashes[index]
            let size = torrent.calculatePieceSize(index: index)
            return PieceWork(index: index, hash: hash, length: size)
        }

        let work = WorkQueue(pieces: pieces)

        work.results.receive(on: DispatchQueue.main).sink { [weak self] data in
            let left = self?.work?.getLeftCount() ?? 0
            let inProgress = self?.work?.getInProgressCount() ?? 0
            print("== COMPLETE: - Piece [\(data.index)] - left: \(left) - in progress: \(inProgress)")
            writer?.write(piece: data)

            if left == 0 && inProgress == 0 {
                writer = nil
                print("== SUCCESS!!!")
                self?.subscribers.removeAll()
                self?.clients = []
            }

        }.store(in: &self.subscribers)

        self.work = work

        self.clients = peers.compactMap {
            let client = PeerClient(torrent: torrent, peer: $0, workQueue: work)
            client?.$state.sink(receiveValue: { state in
                switch state {
                case .initial:
                    self.clientsCount += 1
                case .stopped:
                    self.clientsCount -= 1
                default:
                    break
                }
            }).store(in: &self.subscribers)
            return client
        }

        return writer?.filePath
    }
}