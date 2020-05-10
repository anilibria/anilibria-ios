import IGListKit
import UIKit

public enum SearchValue {
    case series(Series)
    case google(String)
    case filter
}

public final class SearchItem: NSObject {
    let value: SearchValue

    init(_ value: SearchValue) {
        self.value = value
    }
}

final class SearchResultAdapterCreator: BaseInteractiveAdapterCreator<SearchItem, SearchResultAdapter> {}

struct SearchResultAdapterHandler {
    let select: Action<SearchValue>?
}

public final class SearchResultAdapter: ListSectionController, Interactable {
    typealias Handler = SearchResultAdapterHandler
    var handler: Handler?

    private var item: SearchValue!
    private var size: CGSize = .zero

    private static let template = NewsCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: SearchResultCell.self, at: index)
        cell.configure(self.item)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = (object as? SearchItem)?.value
        let width: CGFloat = self.collectionContext!.containerSize.width
        self.size = CGSize(width: width, height: 50)
    }

    public override func didSelectItem(at index: Int) {
        self.handler?.select?(self.item)
    }
}
