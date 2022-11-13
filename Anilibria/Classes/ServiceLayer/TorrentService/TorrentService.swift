//
//  TorrentService.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine
import Network
import DITranquillity

let keepAlive: [UInt8] = [0, 0, 0, 0]

final class TorrentServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(TorrentServiceImp.init)
            .as(TorrentService.self)
            .lifetime(.single)
    }
}

protocol TorrentService: AnyObject {
    func fetchTorrentData(for url: URL) -> AnyPublisher<TorrentData, Error>
    func download(series: Series, torrent: TorrentData, file: TorrentFile) -> AnyPublisher<URL?, Error>
}

final class TorrentServiceImp: TorrentService {
    private let session: URLSession
    private let responseParser: TorrentTrackerResponseParser
    private var client: TorrentClient?

    enum TorrentError: Error {
        case wrongTrackerUrl
    }

    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
        self.responseParser = TorrentTrackerResponseParser()
    }

    func fetchTorrentData(for url: URL) -> AnyPublisher<TorrentData, Error> {
        return session.dataTaskPublisher(for: url).tryMap { response in
            try self.responseParser.parse(from: response.data)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func download(series: Series, torrent: TorrentData, file: TorrentFile) -> AnyPublisher<URL?, Error> {
        guard let url = torrent.buildTrackerUrl() else { return .fail(TorrentError.wrongTrackerUrl) }

        return session.dataTaskPublisher(for: url).tryMap { [weak self] response in
            guard let self = self else { throw AppError.error(code: -1) }
            let tracker: Tracker = try self.responseParser.parse(from: response.data)
            self.client = TorrentClient(series: series, torrent: torrent, peers: tracker.peers)
            return self.client?.download(file: file)
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
