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
