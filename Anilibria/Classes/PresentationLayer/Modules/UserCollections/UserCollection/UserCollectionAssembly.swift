//
//  UserCollectionAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class UserCollectionAssembly {
    static func createModule(type: UserCollectionType?, parent: Router? = nil) -> UserCollectionViewController {
        let module = UserCollectionViewController()
        let router = UserCollectionRouter(view: module, parent: parent)
        if let type {
            let viewModel: UserCollectionViewModel = MainAppCoordinator.shared.container.resolve()
            viewModel.bind(type: type, router: router)
            module.viewModel = viewModel
        } else {
            let viewModel: FavoriteViewModel = MainAppCoordinator.shared.container.resolve()
            viewModel.bind(router: router)
            module.viewModel = viewModel
        }
        return module
    }
}
