//
//  LinkDeviceAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

final class LinkDeviceAssembly {
    static func createModule(parent: Router? = nil) -> LinkDeviceViewController {
        let module = LinkDeviceViewController()
        let router = LinkDeviceRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol LinkDeviceRoute {
    func openDeviceLinker()
}

extension LinkDeviceRoute where Self: RouterProtocol {
    func openDeviceLinker() {
        let module = LinkDeviceAssembly.createModule(parent: self)
        PresentRouter(
            target: module,
            from: nil,
            use: BlurPresentationController.self,
            configure: {
                $0.isBlured = false
                $0.transformation = ScaleTransformation()
            }
        ).move()
    }
}
