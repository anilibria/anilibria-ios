//
//  MRTorrentListContracts.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - Contracts

protocol TorrentListViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(title: String)
    func set(items: [SeriesFile])
}

protocol TorrentListEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: TorrentListViewBehavior, router: TorrentListRoutable, metadata: TorrentMetaData, series: Series)

    func select(file: SeriesFile)
}
