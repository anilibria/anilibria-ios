import UIKit

final class FavoriteAssembly {
    class func createModule(parent: Router? = nil) -> FavoriteViewController {
        let module = FavoriteViewController()
        let router = FavoriteRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol FavoriteRoute {}

extension FavoriteRoute where Self: RouterProtocol {}
