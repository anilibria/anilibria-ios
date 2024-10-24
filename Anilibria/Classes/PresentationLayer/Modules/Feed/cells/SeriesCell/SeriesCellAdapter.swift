import UIKit

final class SeriesCellAdapter: BaseCellAdapter<Series> {
    private var selectAction: ((Series) -> Void)?

    init(viewModel: Series, seclect: ((Series) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

//    override func sizeForItem(at index: IndexPath,
//                              collectionView: UICollectionView,
//                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 140)
//    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: SeriesCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}
