import UIKit

final class SeriesAssembly {
    class func createModule(series: Series, parent: Router? = nil) -> SeriesViewController {
        let module = SeriesViewController()
        let router = SeriesRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, series: series)
        return module
    }
}

// MARK: - Route

protocol SeriesRoute {
    func open(series: Series)
}

extension SeriesRoute where Self: RouterProtocol {
    func open(series: Series) {
        let module = SeriesAssembly.createModule(series: series, parent: self)

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
