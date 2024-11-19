//
//  ScheduleSeriesSectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

final class SoonSectionAdapter: SectionAdapterProtocol {
    let uid = UUID()
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

    func getSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(115),
            heightDimension: .absolute(165)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(115),
            heightDimension: .absolute(165)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }
}
