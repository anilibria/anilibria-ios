import UIKit

final class OtherAssembly {
    class func createModule(parent: Router? = nil) -> OtherViewController {
        let module = OtherViewController()
        let router = OtherRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol OtherRoute {}

extension OtherRoute where Self: RouterProtocol {}
