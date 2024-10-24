import UIKit

public enum SearchValue: Hashable {
    case series(Series)
    case google(String)
    case filter
}

final class SearchResultAdapter: BaseCellAdapter<SearchValue> {
    private var selectAction: ((SearchValue) -> Void)?

    init(viewModel: SearchValue, seclect: ((SearchValue) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

//    override func sizeForItem(at index: IndexPath,
//                              collectionView: UICollectionView,
//                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 50)
//    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: SearchResultCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}
