//
//  EpisodesSectionAdapter.swift
//  AniLiberty
//
//  Created by Ivan Morozov on 30.04.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import UIKit

class EpisodesSectionAdapter: SectionAdapterProtocol {
    let uid: AnyHashable = UUID()
    private(set) var items: OrderedSet<AnyCellAdapter> = []

    private let insets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
    private let expectedWidth: CGFloat = 220
    private let estimatedHeight: CGFloat = 156
    var isCompact: Bool = true


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
        if isCompact {
            return getCompactLayout(environment)
        }
        return getLayout(environment)
    }

    private func getLayout(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let itemsPerLine = max(floor(environment.container.effectiveContentSize.width / expectedWidth), 1)
        let horizontalInsets: CGFloat = insets.leading + insets.trailing
        let width = floor((environment.container.effectiveContentSize.width - horizontalInsets) / itemsPerLine)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(width),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: Int(itemsPerLine))
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = insets
        return section
    }

    private func getCompactLayout(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(expectedWidth),
            heightDimension: .absolute(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(expectedWidth),
            heightDimension: .absolute(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = insets
        return section
    }
}
