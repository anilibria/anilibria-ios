import UIKit

public final class FilterHeaderItem: NSObject {
    var filter: SeriesFilter
    init(_ item: SeriesFilter) {
        self.filter = item
    }
}

final class FilterHeaderAdapter: BaseCellAdapter<FilterHeaderItem> {
    private let action: ((SeriesFilter) -> Void)?

    init(viewModel: FilterHeaderItem, action: ((SeriesFilter) -> Void)?) {
        self.action = action
        super.init(viewModel: viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        var width: CGFloat = UIApplication.keyWindowSize.width
        width = min(width, 414)
        return CGSize(width: width, height: 160)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterHeaderCell.self, for: index)
        cell.configure(viewModel, handler: action)
        return cell
    }
}
