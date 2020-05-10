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
