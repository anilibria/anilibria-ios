//
//  EpisodesAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 28.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class EpisodesAssembly {
    static func createModule(series: Series, parent: Router? = nil) -> EpisodesViewController {
        let module = EpisodesViewController()
        let router = EpisodesRouter(view: module, parent: parent)
        module.viewModel = MainAppCoordinator.shared.container.resolve()
        module.viewModel?.bind(series: series, router: router)
        return module
    }
}

// MARK: - Route

protocol EpisodesRoute {
    func openEpisodes(for series: Series)
}

extension EpisodesRoute where Self: RouterProtocol {
    func openEpisodes(for series: Series) {
        let module = EpisodesAssembly.createModule(series: series, parent: self)
        PushRouter(target: module, parent: controller).move()
    }
}
