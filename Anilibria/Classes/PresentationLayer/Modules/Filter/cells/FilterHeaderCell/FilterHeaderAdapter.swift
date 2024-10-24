import UIKit

public final class FilterHeaderItem: NSObject {}

final class FilterHeaderAdapter: BaseCellAdapter<FilterHeaderItem> {
    init() {
        super.init(viewModel: FilterHeaderItem())
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: FilterHeaderCell.self, for: index)
        return cell
    }
}
