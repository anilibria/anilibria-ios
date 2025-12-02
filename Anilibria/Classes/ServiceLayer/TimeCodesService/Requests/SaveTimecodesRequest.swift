//
//  SaveTimecodesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct SaveTimecodesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    let endpoint: String = "/accounts/users/me/views/timecodes"
    let method: NetworkManager.Method = .POST
    let body: (any Encodable)?
    var headers: [String : String] = [:]

    init(items: [TimeCodePayload]) {
        body = items
    }
}

struct TimeCodePayload: Encodable {
    let episodeID: String
    let isWatched: Bool
    let time: TimeInterval

    enum CodingKeys: String, CodingKey {
        case episodeID = "release_episode_id"
        case isWatched = "is_watched"
        case time
    }
}
