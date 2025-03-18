import DITranquillity
import UIKit

final class ChoiceSheetPart: DIPart {
    static func load(container: DIContainer) {
        container.register(ChoiceSheetPresenter.init)
            .as(ChoiceSheetEventHandler.self)
            .lifetime(.objectGraph)
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

public final class ChoiceGroup: NSObject {
    let title: String?
    let items: [ChoiceItem]
    private var selectedItem: ChoiceItem?

    init(title: String? = nil, items: [ChoiceItem]) {
        self.title = title
        self.items = items
        super.init()

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

// MARK: - Presenter

final class ChoiceSheetPresenter {
    private weak var view: ChoiceSheetViewBehavior!
    private var router: ChoiceSheetRoutable!
    private var source: ChoiceGroupSource?
}

protocol ChoiceGroupSource {
    func fetchItems(_ handler: @escaping ([ChoiceGroup]) -> Void)
}

struct SimpleChoiceGroupSource: ChoiceGroupSource {
    let items: [ChoiceGroup]
    func fetchItems(_ handler: @escaping ([ChoiceGroup]) -> Void) {
        handler(items)
    }
}

extension ChoiceSheetPresenter: ChoiceSheetEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              source: any ChoiceGroupSource) {
        self.view = view
        self.router = router
        self.source = source
    }

    func didLoad() {
        source?.fetchItems { [weak self] items in
            self?.view.set(items: items)
        }
    }

    func back() {
        self.router.back()
    }

    func select(item: ChoiceItem) {
        if item.select() {
            router.back()
        }
    }
}
