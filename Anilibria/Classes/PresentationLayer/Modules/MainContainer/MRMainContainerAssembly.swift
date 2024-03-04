import UIKit

final class MainContainerAssembly {
    class func createModule(parent: Router? = nil) -> MainContainerViewController {
        let module = MainContainerViewController()
        let router = MainContainerRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol MainContainerRoute {}

extension MainContainerRoute where Self: RouterProtocol {}

// MARK: - pages

typealias MenuControllerData = (type: MenuItemType, controller: UIViewController)
public final class MenuItemsControllersFactory {

    static func create(for items: [MenuItem]) -> [MenuControllerData] {
        items.map(create(for:))
    }

    private static func create(for item: MenuItem) -> MenuControllerData {
        var result: UIViewController
        switch item.type {
        case .feed:
            result = FeedAssembly.createModule()
        case .news:
            result = NewsAssembly.createModule()
        case .catalog:
            result = CatalogAssembly.createModule()
        case .other:
            result = OtherAssembly.createModule()
        case .favorite:
            result = FavoriteAssembly.createModule()
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            result = viewForPad(type: item.type, module: result)
        } else {
            result = BaseNavigationController(rootViewController: result)
        }

        return (item.type, result)
    }

    private static func viewForPad(type: MenuItemType, module: UIViewController) -> UIViewController {
        if type == .news {
            return BaseNavigationController(rootViewController: module)
        }

        let splitview = UISplitViewController()
        splitview.preferredPrimaryColumnWidthFraction = 0.5

        #if targetEnvironment(macCatalyst)
        splitview.maximumPrimaryColumnWidth = Sizes.minSize.width/2
        splitview.minimumPrimaryColumnWidth = Sizes.minSize.width/2
        #else
        splitview.maximumPrimaryColumnWidth = 2000
        #endif

        splitview.preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary

        if type == .other {
            let history = HistoryAssembly.createModule()
            splitview.viewControllers = [
                BaseNavigationController(rootViewController: module),
                BaseNavigationController(rootViewController: history)
            ]
        } else {
            splitview.viewControllers = [
                BaseNavigationController(rootViewController: module),
                PlaceholderViewController()
            ]
        }

        return splitview
    }
}
