//
//  FilterSingleItemAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class FilterSingleItem: NSObject {
    let title: String
    @Published var value: String
    @Published var isSelected: Bool
    let action: ((FilterSingleItem) -> Void)

    init(
        title: String,
        value: String,
        selected: Bool,
        action: @escaping ((FilterSingleItem) -> Void)
    ) {
        self.title = title
        self.value = value
        self.isSelected = selected
        self.action = action
    }
}

final class FilterSingleItemAdapter: BaseCellAdapter<FilterSingleItem> {
    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterSingleItemCell.self, for: index)
        cell.configure(with: viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        viewModel.action(viewModel)
    }
}

