import IGListKit
import UIKit

public final class TitleItem: ListItem<String> {}

final class TitleCellAdapterCreator: BaseAdapterCreator<TitleItem, TitleCellAdapter> {}

public final class TitleCellAdapter: ListSectionController {
    private var item: TitleItem!
    private var size: CGSize = .zero

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: TitleCell.self, at: index)
        cell.configure(self.item.value)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? TitleItem
        let width: CGFloat = self.collectionContext!.containerSize.width
        self.size = CGSize(width: width, height: 44)
    }
}
