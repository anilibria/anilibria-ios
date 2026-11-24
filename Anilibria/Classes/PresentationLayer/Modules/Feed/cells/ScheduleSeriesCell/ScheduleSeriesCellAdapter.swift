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
    let uid: AnyHashable = UUID()
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

    func getIdentifiers() -> [AnyHashable] {
        [uid]
    }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        if uid == identifier {
            return items
        }
        return []
    }

    func getSectionLayout(
        for identifier: AnyHashable,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard identifier == uid else { return nil }
        let inset: CGFloat = 16
        let availableWidth = max(1, environment.container.effectiveContentSize.width - 2 * inset)
        let minimumWidth: CGFloat = environment.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 168 : 100
        let columns = max(1, Int(floor((availableWidth + inset) / (minimumWidth + inset))))
        let width = floor((availableWidth - CGFloat(columns - 1) * inset) / CGFloat(columns))
        let heightDimension: NSCollectionLayoutDimension = .absolute(280.0 * width / 195)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(width),
            heightDimension: heightDimension
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: heightDimension
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: columns)
        )

        group.interItemSpacing = .fixed(inset)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = inset
        section.contentInsets = .init(top: 0, leading: inset, bottom: 0, trailing: inset)
        return section
    }
}
