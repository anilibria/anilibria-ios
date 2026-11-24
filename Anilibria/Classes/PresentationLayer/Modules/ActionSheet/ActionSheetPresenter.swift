import DITranquillity
import UIKit

final class ActionSheetPart: DIPart {
    static func load(container: DIContainer) {
        container.register(ActionSheetPresenter.init)
            .as(ActionSheetEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class ActionSheetPresenter {
    private weak var view: ActionSheetViewBehavior!
    private var router: ActionSheetRoutable!
    private var source: ActionSheetGroupSource?
}

protocol ActionSheetGroupSource {
    func fetchItems(_ handler: @escaping ([ChoiceGroup]) -> Void)
}

struct SimpleSheetGroupSource: ActionSheetGroupSource {
    let items: [ChoiceGroup]
    func fetchItems(_ handler: @escaping ([ChoiceGroup]) -> Void) {
        handler(items)
    }
}

extension ActionSheetPresenter: ActionSheetEventHandler {
    func bind(view: ActionSheetViewBehavior,
              router: ActionSheetRoutable,
              source: any ActionSheetGroupSource) {
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

    func select(item: SheetSelector) {
        if item.select() {
            router.back()
        }
    }
}
