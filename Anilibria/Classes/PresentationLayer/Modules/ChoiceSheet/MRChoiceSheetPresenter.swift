import DITranquillity
import UIKit

final class ChoiceSheetPart: DIPart {
    static func load(container: DIContainer) {
        container.register(ChoiceSheetPresenter.init)
            .as(ChoiceSheetEventHandler.self)
            .lifetime(.objectGraph)
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
        let command = ChoiceResult(value: item.value)
        self.router.execute(command)
        self.router.back()
    }
}

public struct ChoiceResult: RouteCommand {
    let value: Any
}
