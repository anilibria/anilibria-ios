import UIKit

final class NewsCellAdapter: BaseCellAdapter<News> {
    private var size: CGSize?
    private var width: CGFloat?
    private var selectAction: ((News) -> Void)?

    init(viewModel: News, seclect: ((News) -> Void)?) {

        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

//    override func sizeForItem(at index: IndexPath,
//                              collectionView: UICollectionView,
//                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
//        if let size = size {
//            return size
//        }
//
//        var width: CGFloat = UIApplication.keyWindowSize.width
//
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            if UIDevice.current.orientation.isLandscape {
//                 width = width / 3
//            } else {
//                 width = width / 2
//            }
//        }
//
//        let height: CGFloat = NewsCell.height(for: viewModel, with: width)
//        let size = CGSize(width: width, height: height)
//        self.size = size
//        return size
//    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: NewsCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}
