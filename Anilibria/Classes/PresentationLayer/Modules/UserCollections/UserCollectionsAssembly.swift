//
//  UserCollectionsAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class UserCollectionsAssembly {
    static func createModule(parent: Router? = nil) -> UserCollectionsViewController {
        let module = UserCollectionsViewController()
        let viewModel = UserCollectionsViewModel()
        module.viewModel = viewModel
        viewModel.collections.forEach {
            module.pages[$0] = UserCollectionAssembly.createModule(type: $0.collectionType, parent: parent)
        }
        return module
    }
}
