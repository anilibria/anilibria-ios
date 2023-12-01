import UIKit

public class FilterTag: NSObject {
    let value: String
    let displayValue: String

    @objc dynamic var isSelected: Bool = false

    init(value: String, displayValue: String? = nil) {
        self.value = value
        self.displayValue = displayValue ?? value
    }
}


public final class FilterTagsItem: NSObject {
    let title: String
    let items: [FilterTag]

    fileprivate let changed: ((FilterTag) -> Void)?

    init(title: String,
         items: [FilterTag],
         changed: @escaping (FilterTag) -> Void) {
        self.title = title
        self.items = items
        self.changed = changed
    }
}

final class FilterTagsTitleAdapter: BaseCellAdapter<FilterTagsItem> {

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        var width: CGFloat = UIApplication.keyWindowSize.width
        width = min(width, 414)
        return CGSize(width: width, height: 40)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterTagTitleCell.self, for: index)
        cell.configure(viewModel.title)
        return cell
    }
}

final class FilterTagAdapter: BaseCellAdapter<FilterTag> {
    private let size: CGSize
    private var selectAction: ((FilterTag) -> Void)?

    init(viewModel: FilterTag, seclect: ((FilterTag) -> Void)?) {
        self.selectAction = seclect
        self.size = FilterTagCell.size(for: viewModel)
        super.init(viewModel: viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        return size
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterTagCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}

class FilterTagsSectionAdapter: SectionAdapter {
    init(item: FilterTagsItem) {
        super.init(
            [FilterTagsTitleAdapter(viewModel: item)] +
            item.items.map { FilterTagAdapter(viewModel: $0, seclect: item.changed) }
        )
        self.insets = .init(top: 0, left: 11, bottom: 0, right: 12)
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAt section: Int) -> UIEdgeInsets {
        self.insets
    }
}
