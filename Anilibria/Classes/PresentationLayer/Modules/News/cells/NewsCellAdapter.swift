//
//  NewsCellAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

final class NewsCellAdapter: BaseCellAdapter<News> {
    private var size: CGSize?
    private var width: CGFloat?
    private var selectAction: ((News) -> Void)?

    init(viewModel: News, seclect: ((News) -> Void)?) {

        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: NewsCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}
