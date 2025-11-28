//
//  EpisodeCellAdapterHandler.swift
//  Anilibria
//
//  Created by Ivan Morozov on 28.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

struct EpisodeCellAdapterHandler {
    let select: ((PlaylistItem) -> Void)?
}

final class EpisodeCellAdapter: BaseCellAdapter<PlaylistItem> {
    private let handler: EpisodeCellAdapterHandler

    init(viewModel: PlaylistItem, handler: EpisodeCellAdapterHandler) {
        self.handler = handler
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: EpisodeCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.handler.select?(viewModel)
    }
}
