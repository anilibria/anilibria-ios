//
//  CollectionContent.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import UIKit

protocol CellAdaptersProvider {
    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter]
}

protocol SectionAdapterProtocol: AnyObject, CellAdaptersProvider {
    func getIdentifiers() -> [AnyHashable]
    func getItems() -> [AnyCellAdapter]

    func set(context: AdapterContext)
    func getSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView?
}

extension SectionAdapterProtocol {
    func set(context: AdapterContext) {}
    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        nil
    }

    func getItems() -> [AnyCellAdapter] {
        getItems(for: getIdentifiers().first)
    }
}

class AnyCellAdapter: Hashable {
    weak var section: (any SectionAdapterProtocol)?

    func hash(into hasher: inout Hasher) {}

    func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        fatalError("override me")
    }

    func didSelect(at index: IndexPath) {}
    func willDisplay(at index: IndexPath) {}
}

extension AnyCellAdapter {
    static func == (lhs: AnyCellAdapter, rhs: AnyCellAdapter) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class BaseCellAdapter<T: Hashable>: AnyCellAdapter {
    let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(viewModel)
    }
}
