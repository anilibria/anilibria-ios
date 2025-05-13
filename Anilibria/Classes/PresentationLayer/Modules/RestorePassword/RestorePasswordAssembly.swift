//
//  RestorePasswordAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

final class RestorePasswordAssembly {
    static func createModule(parent: Router? = nil) -> RestorePasswordViewController {
        let module = RestorePasswordViewController()
        let router = RestorePasswordRouter(view: module, parent: parent)
        module.viewModel = MainAppCoordinator.shared.container.resolve()
        module.viewModel.set(router: router)
        return module
    }
}

// MARK: - Route

protocol RestorePasswordRoute {
    func showRestoreScreen()
}

extension RestorePasswordRoute where Self: RouterProtocol {
    func showRestoreScreen() {
        let module = RestorePasswordAssembly.createModule(parent: self)
        PushRouter(target: module, parent: controller).move()
    }
}
