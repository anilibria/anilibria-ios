import UIKit

public final class ChoiceGroup: NSObject {
    let title: String?
    let items: [ChoiceItem]
    
    init(title: String? = nil, items: [ChoiceItem]) {
        self.title = title
        self.items = items
    }
}

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

final class ChoiceSectionAdapter: SectionAdapter {
    private let title: String?
    
    init(_ group: ChoiceGroup) {
        self.title = group.title
        super.init(group.items.map {
            ChoiceCellAdapter(viewModel: $0)
        })
    }
    
    override func supplementaryForItem(at indexPath: IndexPath, kind: String, context: CollectionContext) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = context.dequeueReusableSupplementaryView(type: ChoiceHaderView.self, ofKind: kind, for: indexPath)
            view.titleLabel.text = title
            return view
        }
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 referenceSizeForHeaderInSection section: Int) -> CGSize {
        if title != nil {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        return .zero
    }
}

class ChoiceCellAdapterSectionFactory {
    class func create(for items: [ChoiceGroup]) -> [any SectionAdapterProtocol] {
        items.map {
            ChoiceSectionAdapter($0)
        }
    }
}
