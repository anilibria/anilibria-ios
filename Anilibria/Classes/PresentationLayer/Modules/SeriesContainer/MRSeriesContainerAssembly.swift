import UIKit

final class SeriesContainerAssembly {
    class func createModule(series: Series, parent: Router? = nil) -> SeriesContainerViewController {
        let module = SeriesContainerViewController()
        let router = SeriesContainerRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, series: series)

        let seriesModule = SeriesAssembly.createModule(series: series, parent: router)
        let commentsModule = CommentsAssembly.createModule(series: series, parent: router)

        module.pages = [seriesModule, commentsModule]

        return module
    }
}

// MARK: - Route

protocol SeriesRoute {
    func open(series: Series)
}

extension SeriesRoute where Self: RouterProtocol {
    func open(series: Series) {
        let module = SeriesContainerAssembly.createModule(series: series, parent: self)

		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			if let secondView = self.controller.splitViewController?.viewControllers.last as? UINavigationController {
				secondView.pushViewController(module, animated: true)
			} else {
				let result = BaseNavigationController(rootViewController: module)
				self.controller.showDetailViewController(result, sender: nil)
				UIApplication.getWindow()?.fadeTransition()
			}
		default:
			PushRouter(target: module, parent: self.controller).move()
		}
    }
}
