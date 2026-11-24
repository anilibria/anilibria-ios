//
//  EpisodeViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 10.02.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import Foundation

struct EpisodeViewModel: Hashable {
    let item: PlaylistItem
    var timecode: TimeCodeData
    let didTapOnWatched: (EpisodeViewModel) -> Void

    func hash(into hasher: inout Hasher) {
        hasher.combine(item)
        hasher.combine(timecode)
    }

    var fullName: String {
        let items: [String?] = [
            item.ordinal.map { "\(NSNumber(value: $0))" },
            item.title
        ]
        return items.compactMap({ $0 }).joined(separator: " ")
    }

    static func == (lhs: EpisodeViewModel, rhs: EpisodeViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
