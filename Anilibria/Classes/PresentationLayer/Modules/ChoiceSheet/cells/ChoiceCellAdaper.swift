import IGListKit
import UIKit

public final class ChoiceItem: NSObject {
    let value: Any
    let title: String
    let isSelected: Bool

    init(_ value: Any, title: String, isSelected: Bool) {
        self.value = value
        self.title = title
        self.isSelected = isSelected
    }
}

final class ChoiceCellAdapterCreator: BaseInteractiveAdapterCreator<ChoiceItem, ChoiceCellAdapter> {}

struct ChoiceCellAdapterHandler {
    let select: Action<ChoiceItem>?
}

public final class ChoiceCellAdapter: ListSectionController, Interactable {
    typealias Handler = ChoiceCellAdapterHandler
    var handler: Handler?

    private var item: ChoiceItem!
    private var size: CGSize = .zero

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: ChoiceCell.self, at: index)
        cell.configure(self.item, isLast: self.isLastSection)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? ChoiceItem
        let width: CGFloat = self.collectionContext!.containerSize.width
        let height: CGFloat = 50
        self.size = CGSize(width: width, height: height)
    }

    public override func didSelectItem(at index: Int) {
        self.handler?.select?(self.item)
    }
}
