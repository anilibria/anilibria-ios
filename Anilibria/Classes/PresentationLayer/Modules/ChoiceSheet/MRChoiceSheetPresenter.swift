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
    let isSelected: Bool

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
        value.select()
    }
}

// MARK: - Presenter

final class ChoiceSheetPresenter {
    private weak var view: ChoiceSheetViewBehavior!
    private var router: ChoiceSheetRoutable!
    private var items: [ChoiceItem] = []
}

extension ChoiceSheetPresenter: ChoiceSheetEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              items: [ChoiceItem]) {
        self.view = view
        self.router = router
        self.items = items
    }

    func didLoad() {
        self.view.set(items: self.items)
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
