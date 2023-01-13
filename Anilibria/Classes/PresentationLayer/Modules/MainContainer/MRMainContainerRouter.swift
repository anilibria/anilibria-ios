import UIKit

// MARK: - Router

protocol MainContainerRoutable: BaseRoutable, AppUrlRoute, SeriesRoute {
    func open(menu type: MenuItemType)
}

final class MainContainerRouter: BaseRouter, MainContainerRoutable {
    weak var originalController: MainContainerViewController?

    init(view: MainContainerViewController, parent: Router? = nil) {
        super.init(view: view, parent: parent)
        self.originalController = view
    }

    func open(menu type: MenuItemType) {
        self.originalController?.set(selected: type)
    }
}
