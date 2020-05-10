import UIKit

final class ConfigurationAssembly {
    class func createModule(parent: Router? = nil) -> ConfigurationViewController {
        let module = ConfigurationViewController()
        let router = ConfigurationRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}
