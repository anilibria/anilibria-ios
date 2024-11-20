import UIKit

final class SoonCellAdapter: BaseCellAdapter<SoonViewModel> {
    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: SoonCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        viewModel.seeAllAction?()
    }
}
