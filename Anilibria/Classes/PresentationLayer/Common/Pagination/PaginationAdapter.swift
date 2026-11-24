//
//  PaginationAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class PaginationAdapter: BaseCellAdapter<PaginationViewModel> {
    private var bag: AnyCancellable?

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: PaginationCell.self, for: index)
        return cell
    }
    
    override func willDisplay(at index: IndexPath) {
        viewModel.load()
        bag = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak viewModel] _ in
                viewModel?.load()
            })
    }

    override func didEndDisplaying(at index: IndexPath) {
        bag = nil
    }
}
