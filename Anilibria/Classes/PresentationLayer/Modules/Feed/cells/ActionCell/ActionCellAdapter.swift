import IGListKit
import UIKit

public final class ActionItem: NSObject {
    let title: String
    private let action: ActionFunc

    init(_ title: String, action: @escaping ActionFunc) {
        self.title = title
        self.action = action
    }

    func execute() {
        self.action()
    }
}

final class ActionCellAdapterCreator: BaseAdapterCreator<ActionItem, ActionCellAdapter> {}

public final class ActionCellAdapter: ListSectionController {
    private var item: ActionItem!
    private var size: CGSize = .zero

    private static let template = NewsCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: ActionCell.self, at: index)
        cell.configure(self.item.title)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? ActionItem
        let width: CGFloat = self.collectionContext!.containerSize.width
        self.size = CGSize(width: width, height: 60)
    }

    public override func didSelectItem(at index: Int) {
        self.item?.execute()
    }
}
