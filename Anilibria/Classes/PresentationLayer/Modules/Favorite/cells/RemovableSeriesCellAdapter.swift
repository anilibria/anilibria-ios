import IGListKit
import UIKit

final class RemovableSeriesCellAdapterCreator: BaseInteractiveAdapterCreator<Series, RemovableSeriesCellAdapter> {}

struct RemovableSeriesCellAdapterHandler {
    let select: Action<Series>?
    let delete: Action<Series>?
}

public final class RemovableSeriesCellAdapter: ListSectionController, Interactable {
    typealias Handler = RemovableSeriesCellAdapterHandler
    var handler: Handler?

    private var item: Series!
    private var size: CGSize = .zero

    private static let template = NewsCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return self.size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(of: RemovableSeriesCell.self, at: index)
        cell.configure(self.item)
        cell.setDelete { [weak self] in
            self?.handler?.delete?(self!.item)
        }
        return cell
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? Series
        let width: CGFloat = self.collectionContext!.containerSize.width
        self.size = CGSize(width: width, height: 140)
    }

    public override func didSelectItem(at index: Int) {
        self.handler?.select?(self.item)
    }
}
