//
//  UserCollectionsViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

final class UserCollectionsViewModel {
    private static let key: String = "UserCollections_KEY"

    var collections: [UserCollectionKey] = [] {
        didSet {
            UserDefaults.standard[Self.key] = collections
        }
    }

    init() {
        self.collections = UserDefaults.standard[Self.key] ?? UserCollectionKey.allCases
    }
}

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

    var title: String {
        collectionType?.localizedTitle ?? L10n.Common.Collections.favorites
    }
}
