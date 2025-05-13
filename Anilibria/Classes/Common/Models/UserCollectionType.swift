//
//  UserCollectionType.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public enum UserCollectionType: String, Codable, CaseIterable {
    case planned = "PLANNED"
    case watching = "WATCHING"
    case postponed = "POSTPONED"
    case watched = "WATCHED"
    case abandoned = "ABANDONED"

    public var localizedTitle: String {
        switch self {
        case .planned: L10n.Common.Collections.planned
        case .watched: L10n.Common.Collections.watched
        case .watching: L10n.Common.Collections.watching
        case .postponed: L10n.Common.Collections.postponed
        case .abandoned: L10n.Common.Collections.abandoned
        }
    }
}
