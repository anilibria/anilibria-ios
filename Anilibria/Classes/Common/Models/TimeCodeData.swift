//
//  TimeCodeData.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct TimeCodeData: Hashable {
    var episodeID: String
    var time: TimeInterval
    var isWatched: Bool
    var updatedAt: Date?

    public init(
        episodeID: String,
        time: TimeInterval = 0,
        isWatched: Bool = false,
        updatedAt: Date? = Date()
    ) {
        self.episodeID = episodeID
        self.time = time
        self.isWatched = isWatched
        self.updatedAt = updatedAt
    }
}
