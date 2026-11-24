//
//  UserCollectionsViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

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
