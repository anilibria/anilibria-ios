//
//  GetTimecodesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct GetTimecodesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [TimeCodeData]

    let endpoint: String = "/accounts/users/me/views/timecodes"
    let method: NetworkManager.Method = .GET
    let parameters: [String : Any]
    var headers: [String : String] = [:]

    init(since: Date? = nil) {
        let formatter = ISO8601DateFormatter()
        self.parameters = if let since {
            ["since": formatter.string(from: since)]
        } else {
            [:]
        }
    }
}

struct TimeCodeData: Decodable {
    let episodeID: String
    let time: TimeInterval
    let isWatched: Bool

    enum CodingKeys: CodingKey {
        case episodeID
        case isWatched
        case time
    }

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        episodeID = try container.decode(String.self)
        time = try container.decode(TimeInterval.self)
        isWatched = try container.decode(Bool.self)
    }
}
