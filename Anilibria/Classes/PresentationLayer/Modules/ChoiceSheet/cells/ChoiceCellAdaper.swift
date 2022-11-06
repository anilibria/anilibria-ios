import UIKit

public final class ChoiceItem: NSObject {
    let value: Any
    let title: String
    let isSelected: Bool
    let isLast: Bool

    var didSelect: ((ChoiceItem) -> Void)?

    init(_ value: Any, title: String, isSelected: Bool, isLast: Bool) {
        self.value = value
        self.title = title
        self.isSelected = isSelected
        self.isLast = isLast
    }
}

final class ChoiceCellAdapter: BaseCellAdapter<ChoiceItem> {
    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ChoiceCell.self, for: index)
        cell.configure(self.viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        viewModel.didSelect?(viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                     collectionView: UICollectionView,
                     layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 50)
    }
}

class ChoiceCellAdapterSectionFactory {
    class func create(for items: [ChoiceItem]) -> any SectionAdapterProtocol {
        SectionAdapter(items.map {
            ChoiceCellAdapter(viewModel: $0)
        })
    }
}
