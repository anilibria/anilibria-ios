//
//  TorrentDownloadOperation.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class TorrentDownloadOperation: Loggable {
    var defaultLoggingTag: LogTag { .model }

    private let progressSubject = CurrentValueSubject<Double, Never>(0)
    private let speedSubject = CurrentValueSubject<String, Never>("")
    private let peersCountSubject = CurrentValueSubject<Int, Never>(0)
    private let isCompletedSubject = CurrentValueSubject<Bool, Never>(false)
    private let downloadedSizeSubject: CurrentValueSubject<Int, Never>

    private let peersQueue = DispatchQueue(label: "peers.queue")
    private let workRepository = WorkQueueRepository()
    private let series: SeriesFile
    private let peers: [Peer]

    private var clients: Set<PeerClient> = []

    private var subscribers = Set<AnyCancellable>()
    private var downloadTask: Task<Void, Never>?

    init(series: SeriesFile, peers: [Peer]) {
        self.series = series
        self.peers = peers
        downloadedSizeSubject = CurrentValueSubject(series.fileSize)
    }

    var progress: AnyPublisher<Double, Never> {
        progressSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var speed: AnyPublisher<String, Never> {
        speedSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var peersCount: AnyPublisher<Int, Never> {
        peersCountSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var isCompleted: AnyPublisher<Bool, Never> {
        isCompletedSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var downloadedSize: AnyPublisher<Int, Never> {
        downloadedSizeSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    func download() {
        if isCompletedSubject.value {
            return
        }
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
                speedSubject.send("\(speed)/c")

                if await writer?.write(piece: data) == true {
                    await work.setCompletedPiece(data)
//                    let inProgress = await work.getInProgressCount()
//                    let left = await work.getLeftCount()
                    let progress = await work.getProgress()
                    let percentage = Double(Int((progress.fractionCompleted) * 10000))/100
                    downloadedSizeSubject.send(series.fileSize)
                    progressSubject.send(percentage)

                    if progress.isFinished == true {
                        self.subscribers.removeAll()
                        self.clients = []
                        try? workRepository.remove(work: work.queue, for: series)
                        self.isCompletedSubject.send(true)
                    } else {
                        try? workRepository.update(work: work.queue, for: series)
                    }
                }
            }
        }

        peersCountSubject.send(peers.count)
        self.clients = Set(peers.compactMap { peer in
            let client = PeerClient(torrent: series.torrent, peer: peer, workQueue: work, queue: peersQueue)
            client?.statePublisher.filter { $0 == .stopped }
                .first()
                .sink(receiveValue: { [weak self, weak client] state in
                    guard let self, let client else { return }
                    var clientsCount = peersCountSubject.value - 1
                    peersCountSubject.send(clientsCount)
                    self.clients.remove(client)
                    if clientsCount <= 0 {
                        Task {
                            let left = await work.getLeftCount()
                            if left > 0 {
                                self.log(.verbose, "== TRY TO RESTART!!!")
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
