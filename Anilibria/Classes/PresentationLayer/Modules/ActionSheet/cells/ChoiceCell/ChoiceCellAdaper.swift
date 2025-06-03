import UIKit

public final class ChoiceGroup: SheetGroup {
    let items: [ChoiceItem]
    private(set) var selectedItem: ChoiceItem?

    init(title: String? = nil, isExpandable: Bool = false, items: [ChoiceItem]) {
        self.items = items
        super.init(title: title, isExpandable: isExpandable)

        items.forEach {
            $0.didSelect = { [weak self] item in
                self?.selectedItem?.isSelected = false
                item.isSelected = true
                self?.selectedItem = item
            }
        }

        selectedItem = items.first { $0.isSelected }
    }
}

public final class ChoiceItem: NSObject {
    private let value: any ChoiceValue
    let title: String
    @Published var isSelected: Bool
    fileprivate var didSelect: ((ChoiceItem) -> Void)?

    init<T>(
        value: T,
        title: String,
        isSelected: Bool,
        didSelect: @escaping (T) -> Bool
    ) {
        self.value = SomeChoiceValue(value: value, didSelect: didSelect)
        self.title = title
        self.isSelected = isSelected
    }

    fileprivate func select() -> Bool {
        didSelect?(self)
        return value.select()
    }
}

private protocol ChoiceValue {
    func select() -> Bool
}

private struct SomeChoiceValue<T>: ChoiceValue {
    let value: T
    let didSelect: (T) -> Bool

    func select() -> Bool {
        return didSelect(value)
    }
}

final class ChoiceCellAdapter: BaseCellAdapter<ChoiceItem> {
    private var selectAction: ((SheetSelector) -> Void)?

    init(viewModel: ChoiceItem, select: ((SheetSelector) -> Void)?) {
        self.selectAction = select
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ChoiceCell.self, for: index)
        cell.configure(self.viewModel, isLast: self.section?.getItems().count == index.item + 1)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        selectAction?(.make(with: viewModel))
    }
}

final class ChoiceCellSectionAdapter: SheetSectionAdapter {
    init(_ group: ChoiceGroup, select: ((SheetSelector) -> Void)?) {
        super.init(group)
        selectedValue = group.selectedItem?.title
        self.items = group.items.map {
            let model = ChoiceCellAdapter(viewModel: $0, select: { [weak self, weak group] selector in
                select?(selector)
                self?.selectedValue = group?.selectedItem?.title
            })
            model.section = self
            return model
        }
    }
}

private extension SheetSelector {
    static func make(with item: ChoiceItem) -> SheetSelector {
        SheetSelector { item.select() }
    }
}
