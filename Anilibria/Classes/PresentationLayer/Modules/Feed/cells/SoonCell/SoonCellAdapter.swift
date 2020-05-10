import IGListKit
import UIKit

final class SoonCellAdapterCreator: BaseInteractiveAdapterCreator<Schedule, SoonCellAdapter> {}

struct SoonCellAdapterHandler {
    let select: Action<Series>?
}

public final class SoonCellAdapter: ListSectionController, Interactable {
    typealias Handler = SoonCellAdapterHandler
    var handler: Handler?

    private var item: Schedule!
    private var size: CGSize = .zero

    private static let template = NewsCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: SoonCell.self, at: index)
        cell.configure(self.item, handler: self.handler)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? Schedule
        let width: CGFloat = self.collectionContext!.containerSize.width
        let height: CGFloat = SoonCell.height(with: width)
        self.size = CGSize(width: width, height: height)
    }
}
