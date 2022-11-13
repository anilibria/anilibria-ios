//
//  MRTorrentListAssembly.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

final class TorrentListAssembly {
    class func createModule(series: Series, metadata: TorrentMetaData, parent: Router? = nil) -> TorrentListViewController {
        let module = TorrentListViewController()
        let router = TorrentListRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, metadata: metadata, series: series)
        return module
    }
}

// MARK: - Route

protocol TorrentListRoute {
    func open(series: Series, metadata: TorrentMetaData)
}

extension TorrentListRoute where Self: RouterProtocol {
    func open(series: Series, metadata: TorrentMetaData) {
        let module = TorrentListAssembly.createModule(series: series, metadata: metadata, parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
