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
        if items.count == 1 {
            items.first?.selectedItemChanged = { [weak self] in
                self?.back()
            }
        }
        self.view.set(items: self.items)
    }

    func back() {
        items.forEach { $0.completeChoice() }
        self.router.back()
    }
}
