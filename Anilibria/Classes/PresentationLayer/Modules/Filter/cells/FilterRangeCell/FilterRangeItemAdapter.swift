//
//  FilterRangeItemAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 24.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


import UIKit
import Combine

final class FilterRangeItemAdapter: BaseCellAdapter<FilterRangeItem> {
    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterRangeCell.self, for: index)
        cell.configure(with: viewModel)
        return cell
    }
}

public final class FilterRangeItem: NSObject {
    let title: String

    let itemsCount: Int
    var selectedMinIndex: Int?
    var selectedMaxIndex: Int?

    let displayValueFormatter: ((FilterRangeItem) -> String)
    let updateRange: ((FilterRangeItem) -> Void)

    var isSelected: Bool {
        selectedMinIndex != nil && selectedMaxIndex != nil
    }

    var displayValue: String {
        displayValueFormatter(self)
    }

    init(
        title: String,
        itemsCount: Int,
        selectedMinIndex: Int?,
        selectedMaxIndex: Int?,
        displayValueFormatter: @escaping ((FilterRangeItem) -> String),
        updateRange: @escaping ((FilterRangeItem) -> Void)
    ) {
        self.title = title
        self.itemsCount = itemsCount
        self.selectedMinIndex = selectedMinIndex
        self.selectedMaxIndex = selectedMaxIndex
        self.displayValueFormatter = displayValueFormatter
        self.updateRange = updateRange
    }


    func update() {
        updateRange(self)
    }
}
