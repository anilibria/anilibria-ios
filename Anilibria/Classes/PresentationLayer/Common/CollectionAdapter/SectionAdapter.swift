//
//  SectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

class SectionAdapter: SectionAdapterProtocol {
    struct Configuration {
        let ladscapeItemsPerLine: Int
        let portraitItemsPerLine: Int

        var itemsPerLine: Int {
            if UIDevice.current.orientation.isLandscape {
                ladscapeItemsPerLine
            } else {
                portraitItemsPerLine
            }
        }
    }

    let uid: AnyHashable = UUID()
    var insets: NSDirectionalEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    var ipad: Configuration?
    private(set) var items: [AnyCellAdapter] = []


    init(_ items: [AnyCellAdapter]) {
        self.set(items)
    }

    func set(_ items: [AnyCellAdapter]) {
        self.items = items
        self.items.forEach {
            $0.section = self
        }
    }

    func append(_ items: [AnyCellAdapter]) {
        self.items.append(contentsOf: items)
        items.forEach {
            $0.section = self
        }
    }

    func getIdentifiers() -> [AnyHashable] {
        [uid]
    }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        if identifier == uid {
            return items
        }
        return []
    }

    func getSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let configuration = ipad {
                return getIPadLayout(environment, configuration: configuration)
            }
        }
        return getDefaultLayout(environment)
    }

    private func getIPadLayout(_ environment: NSCollectionLayoutEnvironment,
                               configuration: Configuration) -> NSCollectionLayoutSection? {
        let itemsPerLine = CGFloat(configuration.itemsPerLine)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / itemsPerLine),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: configuration.itemsPerLine)
        )
        group.interItemSpacing = .flexible(minimumInteritemSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = insets
        section.interGroupSpacing = minimumLineSpacing
        return section
    }

    private func getDefaultLayout(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .flexible(minimumInteritemSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = insets
        section.interGroupSpacing = minimumLineSpacing
        return section
    }
}
