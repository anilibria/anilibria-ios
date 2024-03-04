//
//  TorrentListItemViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 04.03.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

class TorrentListItemViewModel: Hashable {
    let item: SeriesFile

    var operationUpdated: (() -> Void)?
    var operation: TorrentDownloadOperation? {
        didSet {
            operationUpdated?()
        }
    }

    init(item: SeriesFile, operation: TorrentDownloadOperation?) {
        self.item = item
        self.operation = operation
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(item)
    }

    static func == (lhs: TorrentListItemViewModel, rhs: TorrentListItemViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
