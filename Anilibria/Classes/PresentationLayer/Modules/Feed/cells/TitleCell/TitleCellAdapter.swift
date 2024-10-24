import UIKit

public final class TitleItem: NSObject {
    let localizedTitle: () -> String

    init(_ title: @escaping @autoclosure () -> String) {
        self.localizedTitle = title
    }
}


final class TitleCellAdapter: BaseCellAdapter<TitleItem> {

//    override func sizeForItem(at index: IndexPath,
//                              collectionView: UICollectionView,
//                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
//        CGSize(width: collectionView.frame.width, height: 44)
//    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: TitleCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

}
