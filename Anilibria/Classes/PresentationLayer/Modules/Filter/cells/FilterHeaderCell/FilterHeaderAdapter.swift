import IGListKit
import UIKit

public final class FilterHeaderItem: NSObject {
    var filter: SeriesFilter
    init(_ item: SeriesFilter) {
        self.filter = item
    }
}

final class FilterHeaderAdapterCreator: BaseInteractiveAdapterCreator<FilterHeaderItem, FilterHeaderAdapter> {}

struct FilterHeaderAdapterHandler {
    let changed: Action<SeriesFilter>?
}

public final class FilterHeaderAdapter: ListSectionController, Interactable {
    typealias Handler = FilterHeaderAdapterHandler
    var handler: Handler?

    private var item: FilterHeaderItem!
    private var size: CGSize = .zero

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: FilterHeaderCell.self, at: index)
        cell.configure(self.item, handler: self.handler?.changed)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? FilterHeaderItem
        let width: CGFloat = UIApplication.getWindow()?.frame.width ?? 0
        self.size = CGSize(width: width, height: 160)
    }
}
