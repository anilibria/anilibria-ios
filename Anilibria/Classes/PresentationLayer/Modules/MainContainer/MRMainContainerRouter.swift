import UIKit

// MARK: - Router

protocol MainContainerRoutable: BaseRoutable, AppUrlRoute, SeriesRoute {
    func open(menu type: MenuItemType)
}

final class MainContainerRouter: BaseRouter, MainContainerRoutable {
    weak var container: UIViewController!

    override init(view: UIViewController, parent: Router? = nil) {
        super.init(view: view, parent: parent)
        self.container = view
        self.controller = nil
    }

    func open(menu type: MenuItemType) {
        let module: UIViewController?
        switch type {
        case .feed:
            module = FeedAssembly.createModule()
        case .news:
            module = NewsAssembly.createModule()
        case .catalog:
            module = CatalogAssembly.createModule()
        case .other:
            module = OtherAssembly.createModule()
        case .favorite:
            module = FavoriteAssembly.createModule()
        }

        self.controller = module
        if let value = module {
            let result = BaseNavigationController(rootViewController: value)
            ShowChildRouter(target: result, parent: self.container).move()
        }
    }
}
