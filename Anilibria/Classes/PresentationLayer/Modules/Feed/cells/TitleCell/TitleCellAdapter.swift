import UIKit

public final class TitleItem: NSObject {
    let localizedTitle: () -> String

    init(_ title: @escaping @autoclosure () -> String) {
        self.localizedTitle = title
    }
}


final class TitleCellAdapter: BaseCellAdapter<TitleItem> {

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: TitleCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

}
