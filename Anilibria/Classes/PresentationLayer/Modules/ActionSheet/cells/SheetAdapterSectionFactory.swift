//
//  SheetAdapterSectionFactory.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

enum SheetAdapterSectionFactory {
    static func create(for items: [ChoiceGroup], select: ((SheetSelector) -> Void)?) -> [any SectionAdapterProtocol] {
//        items.map { ChoiceCellSectionAdapter($0, select: select) }
        [SheetSectionsAdapter(items: items, select: select)]
    }
}

import UIKit
import Combine

final class SheetSectionsAdapter: SectionAdapterProtocol {
    private var adapters: [AnyHashable: ChoiceCellSectionAdapter] = [:]
    private var ids: [AnyHashable] = []
    private var context: AdapterContext?

    private var cancellabes = Set<AnyCancellable>()

    init(items: [ChoiceGroup], select: ((SheetSelector) -> Void)?) {
        for item in items {
            let adapter = ChoiceCellSectionAdapter(item, select: select)
            if let id = adapter.getIdentifiers().first {
                adapters[id] = adapter
                ids.append(id)
            }

            adapter.expandingChanged.sink { [weak self] in
                guard let self else { return }
                let expanded = adapters.filter({ $0.value.isExpanded == true }).keys
                if expanded.isEmpty {
                    context?.reload(section: self)
                } else {
                    context?.removeSections(identifiers: Set(ids).subtracting(expanded))
                }
            }
            .store(in: &cancellabes)
        }
    }

    func set(context: AdapterContext) {
        self.context = context
        adapters.values.forEach { $0.set(context: context) }
    }

    func getIdentifiers() -> [AnyHashable] { ids }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        if let identifier {
            return adapters[identifier].flatMap { $0.getItems(for: identifier) } ?? []
        }
        return []
    }

    func getSectionLayout(
        for identifier: AnyHashable,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        return adapters[identifier].flatMap { $0.getSectionLayout(for: identifier, environment: environment) }
    }

    func supplementaryFor(
        identifier: AnyHashable,
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        return adapters[identifier]?.supplementaryFor(
            identifier: identifier,
            elementKind: elementKind,
            index: index,
            context: context
        )
    }
}
