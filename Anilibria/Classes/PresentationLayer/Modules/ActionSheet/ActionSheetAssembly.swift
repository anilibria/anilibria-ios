//
//  ActionSheetAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class ActionSheetAssembly {
    static func createModule(
        source: any ActionSheetGroupSource,
        parent: Router? = nil
    ) -> ActionSheetViewController {
        let module = ActionSheetViewController()
        let router = ActionSheetRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, source: source)
        return module
    }
}

// MARK: - Route

protocol ActionSheetRoute {
    func openSheet(with source: any ActionSheetGroupSource)
}

extension ActionSheetRoute where Self: RouterProtocol {
    func openSheet(with source: any ActionSheetGroupSource) {
        let module = ActionSheetAssembly.createModule(source: source, parent: self)
        PresentRouter(target: module,
                      from: nil,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = true
                          $0.transformation = MoveUpTransformation()
        }).move()
    }

    func openSheet(with items: [ChoiceGroup]) {
        openSheet(with: SimpleSheetGroupSource(items: items))
    }
}
