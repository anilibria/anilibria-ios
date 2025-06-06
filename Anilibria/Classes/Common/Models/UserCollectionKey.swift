//
//  UserCollectionKey.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.06.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

enum UserCollectionKey: Hashable, Codable, CaseIterable {
    case favorite
    case planned
    case watching
    case postponed
    case watched
    case abandoned

    var collectionType: UserCollectionType? {
        switch self {
        case .favorite: return nil
        case .planned: return .planned
        case .watching: return .watching
        case .postponed: return .postponed
        case .watched: return .watched
        case .abandoned: return .abandoned
        }
    }

    var icon: UIImage {
        switch self {
        case .favorite: return .System.star
        case .planned: return .System.calendar
        case .watching: return .System.play
        case .postponed: return .System.pause
        case .watched: return .System.checkmark
        case .abandoned: return .System.xmark
        }
    }

    var title: String {
        collectionType?.localizedTitle ?? L10n.Common.Collections.favorites
    }
}
