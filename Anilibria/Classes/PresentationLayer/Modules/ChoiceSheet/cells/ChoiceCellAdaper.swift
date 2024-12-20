import UIKit

final class ChoiceCellAdapter: BaseCellAdapter<ChoiceItem> {
    private var selectAction: ((ChoiceItem) -> Void)?

    init(viewModel: ChoiceItem, seclect: ((ChoiceItem) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ChoiceCell.self, for: index)
        cell.configure(self.viewModel, isLast: self.section?.getItems().count == index.item + 1)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        selectAction?(viewModel)
    }
}

class ChoiceCellAdapterSectionFactory {
    class func create(for items: [ChoiceGroup], seclect: ((ChoiceItem) -> Void)?) -> [any SectionAdapterProtocol] {
        items.map { ChoiceCellSectionAdapter($0, seclect: seclect) }
    }
}

class ChoiceCellSectionAdapter: SectionAdapterProtocol {
    private let headerKind = "ChoiceSectionTitle"
    private let title: String?
    private let uid: AnyHashable = UUID()
    private(set) var items: [AnyCellAdapter] = []

    init(_ group: ChoiceGroup, seclect: ((ChoiceItem) -> Void)?) {
        self.title = group.title
        self.items = group.items.map {
            let model = ChoiceCellAdapter(viewModel: $0, seclect: seclect)
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

    func getSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
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
                    heightDimension: .estimated(1)
                ),
                elementKind: headerKind,
                alignment: .top
            )

            header.pinToVisibleBounds = false
            section.boundarySupplementaryItems = [header]
        }

        return section
    }

    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        if elementKind == headerKind {
            let view = context.dequeueReusableSupplementaryView(
                type: ChoiceHaderView.self,
                ofKind: headerKind,
                for: index
            )
            view.titleLabel.text = title
            return view
        }
        return nil
    }
}
