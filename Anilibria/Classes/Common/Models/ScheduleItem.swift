//
//  ScheduleItem.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ScheduleItem: Decodable, Hashable {
    let item: Series
    let newEpisode: PlaylistItem?
    let newEpisodeOrdinal: Double?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        self.item = try container.decode(required: "release")
        self.newEpisode = container.decode("published_release_episode")
        self.newEpisodeOrdinal = container.decode("next_release_episode_number")
    }
}
