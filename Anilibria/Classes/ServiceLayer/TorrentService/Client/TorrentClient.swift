//
//  TorrentClient.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class TorrentClient: Loggable {
    var defaultLoggingTag: LogTag { .model }
    private let peersQueue = DispatchQueue(label: "peers.queue")

    private let workRepository = WorkQueueRepository()
    let series: SeriesFile
    let peers: [Peer]

    var clients: Set<PeerClient> = []

    var subscribers = Set<AnyCancellable>()
    private var downloadTask: Task<Void, Never>?

    init(series: SeriesFile, peers: [Peer]) {
        self.series = series
        self.peers = peers
    }

    var clientsCount = 0

    func download() {
        let workQueue = workRepository.getWork(for: series)
        let work = WorkQueueActor(queue: workQueue)
        self.subscribers.removeAll()
        self.downloadTask?.cancel()

        downloadTask = Task {
            let startTime = Date()
            var downloaded: Double = 0
            let writer = try? TorrentFileWriter(series: series)

            for await data in await work.results {
                downloaded += Double(data.downloaded)
                let speed = Int64(downloaded / abs(startTime.timeIntervalSinceNow)).binaryCountFormatted
                log(.verbose, "=-= Speed: \(speed)/c")

                if await writer?.write(piece: data) == true {
                    await work.setCompletedPiece(data)
                    let inProgress = await work.getInProgressCount()
                    let progress = await work.getProgress()
                    let left = await work.getLeftCount()
                    let percentage = Double(Int((progress.fractionCompleted) * 10000))/100
                    let peers = self.clientsCount
                    let info = "Piece [\(data)] - left: \(left) - in progress: \(inProgress) : \(percentage)% peers: \(peers)"
                    self.log(.verbose, "== COMPLETE: - \(info)")

                    if progress.isFinished == true {
                        self.log(.verbose, "== SUCCESS!!!")
                        self.subscribers.removeAll()
                        self.clients = []
                        try? workRepository.remove(work: work.queue, for: series)
                    } else {
                        try? workRepository.update(work: work.queue, for: series)
                    }
                }
            }
        }

        self.clientsCount = peers.count
        self.clients = Set(peers.compactMap { peer in
            let client = PeerClient(torrent: series.torrent, peer: peer, workQueue: work, queue: peersQueue)
            client?.statePublisher.filter { $0 == .stopped }
                .first()
                .sink(receiveValue: { [weak self, weak client] state in
                    guard let self, let client else { return }
                    clientsCount -= 1
                    self.clients.remove(client)
                    if clientsCount <= 0 {
                        Task {
                            let left = await work.getLeftCount()
                            if left > 0 {
                                self.log(.verbose, "== clientsCount: \(self.clientsCount) TRY TO RESTART!!!")
                                self.download()
                            }
                        }
                    }
                })
                .store(in: &self.subscribers)
            return client
        })
    }
}
