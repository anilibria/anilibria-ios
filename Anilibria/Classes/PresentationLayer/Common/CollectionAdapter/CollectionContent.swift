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

class CompositeSectionAdapter: SectionAdapterProtocol {
    private let uid = UUID()
    private var items: [any SectionAdapterProtocol]

    func getIdentifier() -> AnyHashable {
        uid
    }

    init(_ items: [any SectionAdapterProtocol]) {
        self.items = items
    }

    func getItems() -> [any CellAdapterProtocol] {
        items.reduce([any CellAdapterProtocol]()) { partialResult, section in
            partialResult + section.getItems()
        }
    }
}

class SectionAdapter: SectionAdapterProtocol {
    let uid = UUID()
    var insets: UIEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    private(set) var items: [any CellAdapterProtocol] = []

    init(_ items: [any CellAdapterProtocol]) {
        self.set(items)
    }

    func set(_ items: [any CellAdapterProtocol]) {
        self.items = items
        self.items.forEach {
            $0.section = self
        }
    }

    func getIdentifier() -> AnyHashable {
        uid
    }

    func getItems() -> [any CellAdapterProtocol] {
        items
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        insets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacing
    }
}

protocol CellAdaptersProvider {
    func getItems() -> [any CellAdapterProtocol]
}

protocol SectionAdapterProtocol: AnyObject, CellAdaptersProvider {
    func getIdentifier() -> AnyHashable

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
}

extension SectionAdapterProtocol {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

protocol CellAdapterProtocol: Hashable, AnyObject {
    // must be weak
    var section: (any SectionAdapterProtocol)? { get set }

    func sizeForItem(at index: IndexPath, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGSize
    func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell?
    func didSelect(at index: IndexPath)
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

    func sizeForItem(at index: IndexPath, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        .zero
    }
}
