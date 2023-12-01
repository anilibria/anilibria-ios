import UIKit

public final class ActionItem: NSObject {
    let localizedTitle: () -> String
    private let action: ActionFunc

    init(_ title: @escaping @autoclosure () -> String, action: @escaping ActionFunc) {
        self.localizedTitle = title
        self.action = action
    }

    func execute() {
        self.action()
    }
}

final class ActionCellAdapter: BaseCellAdapter<ActionItem> {
    private var size: CGSize?

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        return  CGSize(width: collectionView.frame.width, height: 60)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ActionCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        viewModel.execute()
    }
}
