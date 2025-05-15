//
//  UserCollectionKeyAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class UserCollectionKeyViewModel: Hashable {
    let key: UserCollectionKey
    @Published var isSelected: Bool = false

    init(key: UserCollectionKey, isSelected: Bool) {
        self.key = key
        self.isSelected = isSelected
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public static func == (lhs: UserCollectionKeyViewModel, rhs: UserCollectionKeyViewModel) -> Bool {
        lhs.key == rhs.key
    }
}

final class UserCollectionKeyAdapter: BaseCellAdapter<UserCollectionKeyViewModel> {
    fileprivate var setSelected: ((UserCollectionKeyViewModel) -> Void)?

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: UserCollectionKeyCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        setSelected?(viewModel)
    }
}

class UserCollectionKeySectionAdapter: SectionAdapterProtocol {
    private var selected: UserCollectionKeyViewModel?
    private let uid: AnyHashable = UUID()
    private(set) var items: [UserCollectionKeyAdapter] = []

    var didSelect: ((UserCollectionKey) -> Void)?

    init(keys: [UserCollectionKey]) {
        self.items = keys.enumerated().map { index, key in
            let model = UserCollectionKeyAdapter(viewModel: .init(
                key: key,
                isSelected: index == 0
            ))
            model.section = self
            model.setSelected = { [weak self] value in
                if self?.selected == value {
                    return
                }
                self?.selected?.isSelected = false
                value.isSelected = true
                self?.selected = value
                self?.didSelect?(value.key)
            }
            if index == 0 {
                self.selected = model.viewModel
            }
            return model
        }
    }

    func update(keys: [UserCollectionKey]) {
        var result: [UserCollectionKeyAdapter] = []
        keys.forEach { key in
            if let item = items.first(where: { $0.viewModel.key == key }) {
                result.append(item)
            }
        }
        self.items = result
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
            widthDimension: .estimated(50),
            heightDimension: .absolute(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = if UIDevice.current.userInterfaceIdiom == .pad {
            NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(30)
            )
        } else {
            NSCollectionLayoutSize(
                widthDimension: .estimated(50),
                heightDimension: .absolute(40)
            )
        }
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }
}
