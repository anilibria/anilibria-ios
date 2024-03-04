//
//  TorrentFileCellAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

final class TorrentFileCellAdapter: BaseCellAdapter<TorrentListItemViewModel> {
    private var selectAction: ((TorrentListItemViewModel) -> Void)?

    init(viewModel: TorrentListItemViewModel, seclect: ((TorrentListItemViewModel) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 140)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: TorrentFileCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}
