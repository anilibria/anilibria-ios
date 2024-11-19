import UIKit

final class ScheduleSeriesCellAdapter: BaseCellAdapter<ScheduleItem> {
    private var size: CGSize?
    private var selectAction: ((Series) -> Void)?

    init(viewModel: ScheduleItem, seclect: ((Series) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ScheduleSeriesCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel.item)
    }
}

final class ScheduleSeriesSectionAdapter: SectionAdapterProtocol {
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
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalWidth(280.0 / (3 * 195))
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(280.0 / (3 * 195))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .flexible(16)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }
}
