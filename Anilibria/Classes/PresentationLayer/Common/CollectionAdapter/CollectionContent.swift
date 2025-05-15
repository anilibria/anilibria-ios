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
    func getSectionLayout(
        for identifier: AnyHashable,
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection?
    func supplementaryFor(
        identifier: AnyHashable,
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView?
}

extension SectionAdapterProtocol {
    func set(context: AdapterContext) {}
    func supplementaryFor(
        identifier: AnyHashable,
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

struct SectionData: Hashable {
    let id: AnyHashable
    private weak var section: (any SectionAdapterProtocol)?

    init(id: AnyHashable, section: any SectionAdapterProtocol) {
        self.id = id
        self.section = section
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SectionData, rhs: SectionData) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func getSectionLayout(
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        section?.getSectionLayout(for: id, environment: environment)
    }

    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        section?.supplementaryFor(
            identifier: id,
            elementKind: elementKind,
            index: index,
            context: context
        )
    }
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
