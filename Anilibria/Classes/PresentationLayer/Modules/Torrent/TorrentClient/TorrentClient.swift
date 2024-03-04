//
//  TorrentClient.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.03.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

final class TorrentClient {
    static let instance: TorrentClient = .init()

    private var operations: [URL: TorrentDownloadOperation] = [:]

    private let session: URLSession
    private let responseParser: TorrentTrackerResponseParser

    enum TorrentError: Error {
        case wrongTrackerUrl
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
        self.responseParser = TorrentTrackerResponseParser()
    }

    func getExistingOperation(for series: SeriesFile) -> TorrentDownloadOperation? {
        operations[series.filePath]
    }

    func makeOperation(series: SeriesFile) -> AnyPublisher<TorrentDownloadOperation, Error> {
        if let operation = operations[series.filePath] {
            return .just(operation)
        }

        guard let url = series.torrent.buildTrackerUrl() else {
            return .fail(TorrentError.wrongTrackerUrl)
        }

        return session.dataTaskPublisher(for: url).tryMap { [weak self] response in
            guard let self = self else { throw AppError.error(code: -1) }
            let tracker: Tracker = try self.responseParser.parse(from: response.data)
            let operation = TorrentDownloadOperation(series: series, peers: tracker.peers)
            self.operations[series.filePath] = operation
            return operation
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
