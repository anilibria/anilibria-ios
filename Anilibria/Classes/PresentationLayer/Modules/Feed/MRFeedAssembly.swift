import UIKit

final class FeedAssembly {
    static func createModule(parent: Router? = nil) -> FeedViewController {
        let module = FeedViewController()
        let router = FeedRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol FeedRoute {}

extension FeedRoute where Self: RouterProtocol {}
