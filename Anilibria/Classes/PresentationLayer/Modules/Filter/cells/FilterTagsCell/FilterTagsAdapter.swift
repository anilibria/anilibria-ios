import IGListKit
import UIKit

public final class FilterTagsItem: NSObject {
    let title: String
    let items: [Selectable<String>]

    fileprivate let changed: Action<Selectable<String>>

    init(title: String,
         items: [Selectable<String>],
         changed: @escaping Action<Selectable<String>>) {
        self.title = title
        self.items = items
        self.changed = changed
    }
}

final class FilterTagsAdapterCreator: BaseAdapterCreator<FilterTagsItem, FilterTagsAdapter> {}

public final class FilterTagsAdapter: ListSectionController {
    private var item: FilterTagsItem!
    private var sizes: [CGSize] = []

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.sizes[index]
    }

    public override func numberOfItems() -> Int {
        return self.item.items.count + 1
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        if index == 0 {
            let cell = self.dequeueReusableCell(of: FilterTagTitleCell.self, at: index)
            cell.configure(self.item.title)
            return cell
        }
        let cell = self.dequeueReusableCell(of: FilterTagCell.self, at: index)
        cell.configure(self.item.items[index - 1])
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? FilterTagsItem
        var width: CGFloat = UIApplication.getWindow()?.frame.width ?? 0
		width = min(width, 414)
        self.sizes = [CGSize(width: width, height: 40)]
        self.sizes = self.sizes + self.item.items.map(FilterTagCell.size)
    }

    public override func didSelectItem(at index: Int) {
        if index == 0 {
            return
        }

        self.item.changed(self.item.items[index - 1])
    }
}
