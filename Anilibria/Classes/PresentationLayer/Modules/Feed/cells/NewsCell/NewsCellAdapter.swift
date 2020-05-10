import IGListKit
import UIKit

final class NewsCellAdapterCreator: BaseInteractiveAdapterCreator<News, NewsCellAdapter> {}

struct NewsCellAdapterHandler {
    let select: Action<News>?
}

public final class NewsCellAdapter: ListSectionController, Interactable {
    typealias Handler = NewsCellAdapterHandler
    var handler: Handler?

    private var item: News!
    private var size: CGSize = .zero

    private static let template = NewsCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: NewsCell.self, at: index)
        cell.configure(self.item)
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? News
        let width: CGFloat = self.collectionContext!.containerSize.width
        let height: CGFloat = NewsCell.height(for: self.item, with: width)
        self.size = CGSize(width: width, height: height)
    }

    public override func didSelectItem(at index: Int) {
        self.handler?.select?(self.item)
    }
}
