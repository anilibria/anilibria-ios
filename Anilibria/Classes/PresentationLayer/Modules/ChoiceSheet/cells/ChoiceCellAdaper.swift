import UIKit

final class ChoiceCellAdapter: BaseCellAdapter<ChoiceItem> {
    private var selectAction: ((ChoiceItem) -> Void)?

    init(viewModel: ChoiceItem, seclect: ((ChoiceItem) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ChoiceCell.self, for: index)
        cell.configure(self.viewModel, isLast: self.section?.getItems().count == index.item + 1)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        selectAction?(viewModel)
    }
}

class ChoiceCellAdapterSectionFactory {
    class func create(for items: [ChoiceItem], seclect: ((ChoiceItem) -> Void)?) -> any SectionAdapterProtocol {
        SectionAdapter(items.map {
            ChoiceCellAdapter(viewModel: $0, seclect: seclect)
        })
    }
}
