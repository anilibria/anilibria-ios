//
//  TimeCodeData.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct TimeCodeData: Hashable, Decodable {
    var episodeID: String
    var userID: Int?
    var time: TimeInterval
    var isWatched: Bool
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case episodeID = "release_episode_id"
        case userID = "user_id"
        case isWatched = "is_watched"
        case updatedAt = "updated_at"
        case time
    }

    public init(
        episodeID: String,
        userID: Int?,
        time: TimeInterval = 0,
        isWatched: Bool = false,
        updatedAt: Date? = Date()
    ) {
        self.episodeID = episodeID
        self.userID = userID
        self.time = time
        self.isWatched = isWatched
        self.updatedAt = updatedAt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        episodeID = try container.decode(required: .episodeID)
        userID = container.decode(.userID)
        time = container.decode(.time) ?? 0
        isWatched = container.decode(.isWatched) ?? false
        updatedAt = container.decode(.updatedAt)
    }
}
