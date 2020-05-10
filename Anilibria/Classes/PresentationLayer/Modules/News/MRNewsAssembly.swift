import UIKit

final class NewsAssembly {
    class func createModule(parent: Router? = nil) -> NewsViewController {
        let module = NewsViewController()
        let router = NewsRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol NewsRoute {}

extension NewsRoute where Self: RouterProtocol {}
