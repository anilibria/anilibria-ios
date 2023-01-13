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
    private let workRepository = WorkQueueRepository()
    let series: SeriesFile
    let peers: [Peer]
    var work: WorkQueue?

    var clients: [PeerClient] = []

    var subscribers = Set<AnyCancellable>()

    init(series: SeriesFile, peers: [Peer]) {
        self.series = series
        self.peers = peers
    }

    var clientsCount = 0

    func download() {
        var writer = try? TorrentFileWriter(series: series)
        let work = workRepository.getWork(for: series)

        let startTime = Date()
        var downloaded: Double = 0
        let formatter = ByteCountFormatter()
        work.results.receive(on: DispatchQueue.main).sink { [weak self] data in
            downloaded += Double(data.downloaded)
            let speed = formatter.string(fromByteCount: Int64(downloaded / abs(startTime.timeIntervalSinceNow)))
            print("=-= Speed: \(speed)/c")

            writer?.write(piece: data) { [weak self] succeeded in
                if succeeded {
                    self?.work?.setCompletedPiece(data)
                    self?.saveWork()
                    let left = self?.work?.getLeftCount() ?? 0
                    let inProgress = self?.work?.getInProgressCount() ?? 0
                    let percentage = Double(Int((self?.work?.progress.fractionCompleted ?? 0) * 10000))/100
                    let peers = self?.clientsCount ?? 0
                    print("== COMPLETE: - Piece [\(data)] - left: \(left) - in progress: \(inProgress) : \(percentage)% peers: \(peers)")
                }
            }

            if self?.work?.progress.isFinished == true {
                writer = nil
                print("== SUCCESS!!!")
                self?.subscribers.removeAll()
                self?.clients = []
            }

        }.store(in: &self.subscribers)

        self.work = work

        self.clients = peers.compactMap {
            let client = PeerClient(torrent: series.torrent, peer: $0, workQueue: work)
            client?.$state.sink(receiveValue: { [weak self] state in
                switch state {
                case .initial:
                    self?.clientsCount += 1
                case .stopped:
                    self?.clientsCount -= 1
                default:
                    break
                }
            }).store(in: &self.subscribers)
            return client
        }
    }

    private func saveWork() {
        guard let work = work else { return }
        if work.progress.isFinished == true {
            try? workRepository.remove(work: work, for: series)
        } else {
            try? workRepository.update(work: work, for: series)
        }
    }
}
