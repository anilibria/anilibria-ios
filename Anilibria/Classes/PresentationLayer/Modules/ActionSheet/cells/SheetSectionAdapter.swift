//
//  SheetSectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

class SheetSectionAdapter: SectionAdapterProtocol {
    private let headerKind = "SheetSectionTitle"
    private let title: String?
    private let uid: AnyHashable = UUID()
    private var isExpanded: Bool?
    private var context: AdapterContext?

    var items: [AnyCellAdapter] = []

    init(_ group: SheetGroup) {
        self.title = group.title
        if group.isExpandable && group.title != nil {
            self.isExpanded = false
        }
    }

    func set(context: AdapterContext) {
        self.context = context
    }

    func getIdentifiers() -> [AnyHashable] {
        [uid]
    }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        if identifier == uid {
            if let isExpanded {
                return isExpanded ? items : []
            }
            return items
        }
        return []
    }

    func getSectionLayout(
        for identifier: AnyHashable,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard identifier == uid else { return nil }
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
        let section = NSCollectionLayoutSection(group: group)

        if title != nil {
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(40)
                ),
                elementKind: headerKind,
                alignment: .top
            )

            header.pinToVisibleBounds = false
            section.boundarySupplementaryItems = [header]
        }
        section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(
                elementKind: SectionBackgroundCollectionViewCompositionalLayout.backgroundViewKind
            )
        ]

        return section
    }

    func supplementaryFor(
        identifier: AnyHashable,
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        guard identifier == uid else { return nil }
        if elementKind == headerKind {
            let view = context.dequeueReusableSupplementaryView(
                type: SheetHeaderView.self,
                ofKind: headerKind,
                for: index
            )
            view.set(title: title)
            view.set(expanded: isExpanded, animated: false)
            view.tapAction = { [weak self, weak view] in
                guard let self else { return }
                if let isExpanded {
                    self.isExpanded = !isExpanded
                    view?.set(expanded: self.isExpanded, animated: true)
                }
                self.context?.reload(section: self)
            }
            return view
        }
        return nil
    }
}
