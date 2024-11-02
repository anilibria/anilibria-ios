//
//  CollectionContent.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import UIKit

class CollectionContent {
    class Section {
        let sectionId: Int
        let section: any SectionAdapterProtocol
        var items: [CellAdapterWrapper]

        init(section: any SectionAdapterProtocol, items: [CellAdapterWrapper]) {
            self.section = section
            self.sectionId = section.getIdentifier().hashValue
            self.items = items
        }
    }

    private(set) var sections: [Section]
    private var indexes: Set<Int>

    init(_ items: [any SectionAdapterProtocol]) {
        var groupedItems = [Section]()
        var indexes = Set<Int>()
        for section in items {
            section.getItems().forEach {
                let wrapper = CellAdapterWrapper(item: $0)
                if let section = wrapper.item.section {
                    if groupedItems.last?.section.getIdentifier() != section.getIdentifier() {
                        groupedItems.append(.init(section: section, items: [wrapper]))
                        indexes.insert(section.getIdentifier().hashValue)
                    } else {
                        groupedItems.last?.items.append(wrapper)
                    }
                }
            }
        }

        self.sections = groupedItems
        self.indexes = indexes
    }

    func contains(_ section: Section) -> Bool {
        indexes.contains(section.sectionId)
    }

    func append(_ content: CollectionContent) {
        var sections = content.sections
        if self.sections.last?.sectionId == sections.first?.sectionId {
            let section = sections.removeFirst()
            self.sections.last?.items.append(contentsOf: section.items)
        }
        self.indexes = self.indexes.union(content.indexes)
        self.sections.append(contentsOf: sections)
    }
}

protocol CellAdaptersProvider {
    func getItems() -> [any CellAdapterProtocol]
}

protocol SectionAdapterProtocol: AnyObject, CellAdaptersProvider {
    func getIdentifier() -> AnyHashable

    func getSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView?
}

extension SectionAdapterProtocol {
    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        nil
    }
}

protocol CellAdapterProtocol: Hashable, AnyObject {
    // must be weak
    var section: (any SectionAdapterProtocol)? { get set }

    func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell?
    func didSelect(at index: IndexPath)
    func willDisplay(at index: IndexPath)
}

extension CellAdapterProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class BaseCellAdapter<T: Hashable>: CellAdapterProtocol {
    weak var section: (any SectionAdapterProtocol)?

    let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel)
    }

    func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        fatalError("override me")
    }

    func didSelect(at index: IndexPath) {}
    
    func willDisplay(at index: IndexPath) {}
}
