//
//  SectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

class SectionAdapter: SectionAdapterProtocol {
    let uid: AnyHashable = UUID()
    var insets: NSDirectionalEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    var estimatedHeight: CGFloat = 50
    var minimumColumnWidth: CGFloat?
    private(set) var items: OrderedSet<AnyCellAdapter> = []

    init(_ items: [AnyCellAdapter]) {
        self.set(items)
    }

    func set(_ items: [AnyCellAdapter]) {
        self.items = OrderedSet(items)
        items.forEach {
            $0.section = self
        }
    }

    func append(_ items: [AnyCellAdapter]) {
        self.items.append(items)
        items.forEach {
            $0.section = self
        }
    }

    func getIdentifiers() -> [AnyHashable] {
        [uid]
    }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        if identifier == uid {
            return items.array
        }
        return []
    }

    func getSectionLayout(
        for identifier: AnyHashable,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard identifier == uid else { return nil }
        let availableWidth = environment.container.effectiveContentSize.width - insets.leading - insets.trailing
        let gap = minimumInteritemSpacing
        let columns: Int
        if let minimumColumnWidth, !environment.traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            columns = max(1, Int(floor((availableWidth + gap) / (minimumColumnWidth + gap))))
        } else {
            columns = 1
        }
        let width = floor((availableWidth - CGFloat(columns - 1) * gap) / CGFloat(columns))
        let itemSize = NSCollectionLayoutSize(
            widthDimension: columns == 1 ? .fractionalWidth(1) : .absolute(width),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: columns)
        )
        group.interItemSpacing = .fixed(gap)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = insets
        section.interGroupSpacing = minimumLineSpacing
        return section
    }
}
