import UIKit

final class SoonCellAdapter: BaseCellAdapter<Schedule> {
    private var size: CGSize?
    private var selectAction: ((Series) -> Void)?

    init(viewModel: Schedule, seclect: ((Series) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        if let size = size, size.width == collectionView.frame.width {
            return size
        }

        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = SoonCell.height(with: width)
        let size = CGSize(width: width, height: height)
        self.size = size
        return size
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: SoonCell.self, for: index)
        cell.configure(viewModel, handler: selectAction)
        return cell
    }
}
