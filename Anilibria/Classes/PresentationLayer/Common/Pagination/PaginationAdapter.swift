//
//  PaginationAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit

final class PaginationAdapter: BaseCellAdapter<PaginationViewModel> {
    private var size: CGSize?

//    override func sizeForItem(at index: IndexPath,
//                              collectionView: UICollectionView,
//                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
//        return  CGSize(width: collectionView.frame.width, height: 84)
//    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: PaginationCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }
    
    override func willDisplay(at index: IndexPath) {
        viewModel.load()
    }
}
