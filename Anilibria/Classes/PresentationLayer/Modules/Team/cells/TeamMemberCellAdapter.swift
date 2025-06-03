//
//  TeamMemberCellAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

final class TeamMemberCellAdapter: BaseCellAdapter<TeamMember> {
    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: TeamMemberCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }
}

class TeamMemberSectionAdapter: SectionAdapterProtocol {
    private let headerKind = "TeamMemberTitle"
    private let team: TeamMember.Team
    private let uid: AnyHashable = UUID()
    private(set) var items: [AnyCellAdapter] = []

    init(group: TeamGroup) {
        self.team = group.team
        self.items = group.members.map {
            let model = TeamMemberCellAdapter(viewModel: $0)
            model.section = self
            return model
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

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(50)
            ),
            elementKind: headerKind,
            alignment: .top
        )

        header.pinToVisibleBounds = true

        section.boundarySupplementaryItems = [header]
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
            let view = context.dequeueReusableNibSupplementaryView(
                type: TeamTitleView.self,
                ofKind: headerKind,
                for: index
            )
            view.configure(team)
            return view
        }
        return nil
    }
}
