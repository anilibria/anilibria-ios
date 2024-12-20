//
//  PaginationAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit

final class PaginationAdapter: BaseCellAdapter<PaginationViewModel> {

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: PaginationCell.self, for: index)
        return cell
    }
    
    override func willDisplay(at index: IndexPath) {
        viewModel.load()
    }
}
