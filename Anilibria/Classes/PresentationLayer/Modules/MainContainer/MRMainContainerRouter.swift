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
			let result: UIViewController

			if UIDevice.current.userInterfaceIdiom == .pad {
				result = self.viewForPad(type: type, module: value)
			} else {
				result = BaseNavigationController(rootViewController: value)
			}

            ShowChildRouter(target: result, parent: self.container).move()
        }
    }

	private func viewForPad(type: MenuItemType, module: UIViewController) -> UIViewController {
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
		
		splitview.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible

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
