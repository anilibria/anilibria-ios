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
    func fetchTorrentData(for seriesID: Int, url: URL) -> AnyPublisher<[SeriesFile], Error>
}

final class TorrentServiceImp: TorrentService {
    private let session: URLSession
    private let responseParser: TorrentTrackerResponseParser

    enum TorrentError: Error {
        case wrongTrackerUrl
    }

    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
        self.responseParser = TorrentTrackerResponseParser()
    }

    func fetchTorrentData(for seriesID: Int, url: URL) -> AnyPublisher<[SeriesFile], Error> {
        return session.dataTaskPublisher(for: url).tryMap { response in
            try self.responseParser.parse(from: response.data)
        }
        .map { data -> [SeriesFile] in
            data.content.files.compactMap {
                try? SeriesFile(seriesID: seriesID, torrent: data, file: $0)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
