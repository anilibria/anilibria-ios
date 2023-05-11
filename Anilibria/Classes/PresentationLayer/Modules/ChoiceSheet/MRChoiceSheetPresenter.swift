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
    private var items: [ChoiceGroup] = []
}

extension ChoiceSheetPresenter: ChoiceSheetEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              items: [ChoiceGroup]) {
        self.view = view
        self.router = router
        self.items = items
    }

    func didLoad() {
        self.view.set(items: self.items.map { group in
            group.items.forEach {
                $0.didSelect = { [weak self] item in
                    self?.select(item: item)
                }
            }
            return group
        })
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
