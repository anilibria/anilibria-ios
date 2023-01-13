import UIKit

public final class FilterTagsItem: NSObject {
    let title: String
    let items: [Selectable<String>]

    fileprivate let changed: ((Selectable<String>) -> Void)?

    init(title: String,
         items: [Selectable<String>],
         changed: @escaping (Selectable<String>) -> Void) {
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

final class FilterTagAdapter: BaseCellAdapter<Selectable<String>> {
    private let size: CGSize
    private var selectAction: ((Selectable<String>) -> Void)?

    init(viewModel: Selectable<String>, seclect: ((Selectable<String>) -> Void)?) {
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
