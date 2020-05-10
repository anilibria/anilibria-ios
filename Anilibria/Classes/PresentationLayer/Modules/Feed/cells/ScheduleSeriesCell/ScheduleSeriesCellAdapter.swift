import IGListKit
import UIKit

final class ScheduleSeriesCellAdapterCreator: BaseInteractiveAdapterCreator<Series, ScheduleSeriesCellAdapter> {}

struct ScheduleSeriesCellAdapterHandler {
    let select: Action<Series>?
}

public final class ScheduleSeriesCellAdapter: ListSectionController, Interactable {
    typealias Handler = ScheduleSeriesCellAdapterHandler
    var handler: Handler?

    private var item: Series!
    private var size: CGSize = .zero

    private static let template = NewsCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: ScheduleSeriesCell.self, at: index)
        cell.configure(self.item)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? Series
        self.inset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 0)
        let width: CGFloat = self.collectionContext!.containerSize.width
        self.size = ScheduleSeriesCell.size(with: width, gap: 16)
    }

    public override func didSelectItem(at index: Int) {
        self.handler?.select?(self.item)
    }
}
