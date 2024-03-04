//
//  MRTorrentListView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - View Controller

final class TorrentListViewController: BaseCollectionViewController {
    var handler: TorrentListEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRefreshControl()
        self.handler.didLoad()
        self.collectionView.contentInset.top = 10
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

}

extension TorrentListViewController: TorrentListViewBehavior {
    func set(title: String) {
        self.navigationItem.title = title
    }

    func set(items: [TorrentListItemViewModel]) {
        reload(sections: [SectionAdapter(
            items.map {
                TorrentFileCellAdapter(viewModel: $0) { [weak self] model in
                    self?.handler.select(model: model)
                }
            })
        ])
    }
}
