import UIKit

final class CommentsAssembly {
    class func createModule(series: Series, parent: Router? = nil) -> CommentsViewController {
        let module = CommentsViewController()
        let router = CommentsRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, series: series)
        return module
    }
}
