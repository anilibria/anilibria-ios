import UIKit
import Combine

public protocol FilterTagValue {
    var displayValue: String { get }
    var isSelected: CurrentValueSubject<Bool, Never> { get }
    func select()
}

public final class FilterTagData<T: Hashable>: FilterTagValue {
    public let value: T
    public let displayValue: String

    public let isSelected: CurrentValueSubject<Bool, Never>
    private let didSelect: ((FilterTagData<T>) -> Void)

    init(
        value: T,
        displayValue: String,
        selected: Bool,
        select: @escaping (T) -> Void,
        deselect: @escaping (T) -> Void
    ) {
        self.value = value
        self.displayValue = displayValue
        self.isSelected = .init(selected)
        self.didSelect = { param in
            let selected = !param.isSelected.value
            if selected {
                select(value)
            } else {
                deselect(value)
            }
            param.isSelected.send(selected)
        }
    }

    public func select() {
        didSelect(self)
    }
}

public class FilterTag: NSObject {
    let value: any FilterTagValue
    var displayValue: String {
        value.displayValue
    }

    var isSelected: Bool {
        value.isSelected.value
    }

    init(value: any FilterTagValue) {
        self.value = value
    }
}

public final class FilterTagsItem: NSObject {
    let title: String
    let items: [FilterTag]

    init(title: String,
         items: [any FilterTagValue]) {
        self.title = title
        self.items = items.map({ FilterTag(value: $0) })
    }
}

final class FilterTagAdapter: BaseCellAdapter<FilterTag> {
    private let size: CGSize

    override init(viewModel: FilterTag) {
        self.size = FilterTagCell.size(for: viewModel)
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterTagCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        viewModel.value.select()
    }
}

class FilterTagsSectionAdapter: SectionAdapterProtocol {
    private let headerKind = "FilterTagsTitle"
    private let title: String
    private let uid: AnyHashable = UUID()
    private(set) var items: [AnyCellAdapter] = []

    init(item: FilterTagsItem) {
        self.title = item.title
        self.items = item.items.map {
            let model = FilterTagAdapter(viewModel: $0)
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
            widthDimension: .estimated(50),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .fixed(1)
        group.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(50)
            ),
            elementKind: headerKind,
            alignment: .top
        )

        header.pinToVisibleBounds = false

        section.boundarySupplementaryItems = [header]
        return section
    }

    func supplementaryFor(
        elementKind: String,
        index: IndexPath,
        context: CollectionContext
    ) -> UICollectionReusableView? {
        if elementKind == headerKind {
            let view = context.dequeueReusableNibSupplementaryView(
                type: FilterTitleView.self,
                ofKind: headerKind,
                for: index
            )
            view.configure(title)
            return view
        }
        return nil
    }
}
