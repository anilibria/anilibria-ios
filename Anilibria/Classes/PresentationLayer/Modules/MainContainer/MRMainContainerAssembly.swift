import UIKit

final class MainContainerAssembly {
    static func createModule(parent: Router? = nil) -> MainContainerViewController {
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
        case .collections:
            result = UserCollectionsAssembly.createModule()
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

        let splitview = if type == .other {
            MRSplitViewController(
                primaryController: module,
                secondaryController: HistoryAssembly.createModule()
            )
        } else {
            MRSplitViewController(
                primaryController: module,
                secondaryController: nil
            )
        }
        splitview.preferredPrimaryColumnWidthFraction = 0.5

        splitview.maximumPrimaryColumnWidth = 500
        splitview.minimumPrimaryColumnWidth = 320

        splitview.presentsWithGesture = true
        splitview.preferredDisplayMode = .oneBesideSecondary

        return splitview
    }
}

final class MRSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    private let primaryRootController: UIViewController
    private let secondaryRootController: UIViewController?

    init(primaryController: UIViewController, secondaryController: UIViewController?) {
        self.primaryRootController = primaryController
        self.secondaryRootController = secondaryController
        super.init(nibName: nil, bundle: nil)
        viewControllers.append(BaseNavigationController(rootViewController: primaryController))
        if let secondaryRootController {
            viewControllers.append(BaseNavigationController(rootViewController: secondaryRootController))
        } else {
            viewControllers.append(PlaceholderNavigationController())
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func primaryViewController(
        forCollapsing splitViewController: UISplitViewController
    ) -> UIViewController? {
        splitViewController.viewControllers.first
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        switch secondaryViewController {
        case let controller as BaseNavigationController:
            if let primary = primaryViewController as? BaseNavigationController {
                let secondary = controller.viewControllers
                controller.viewControllers = []
                primary.viewControllers.append(contentsOf: secondary)
            }
        default:
            break
        }
        return true
    }

    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        splitViewController.viewControllers.first
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        separateSecondaryFrom primaryViewController: UIViewController
    ) -> UIViewController? {
        if let primary = primaryViewController as? BaseNavigationController {
            let controllers: [UIViewController] = primary.viewControllers
            let index = controllers.firstIndex(where: {
                $0 is SeriesViewController || $0 == secondaryRootController
            }) ?? 0
            if index > 0 {
                primary.viewControllers = Array(controllers[..<index])
                let secondary = BaseNavigationController()
                secondary.viewControllers = Array(controllers[index...])
                return secondary
            }
        }
        if let secondaryRootController {
            return BaseNavigationController(rootViewController: secondaryRootController)
        }

        return PlaceholderNavigationController()
    }
}
