import UIKit

final class SettingsAssembly {
    class func createModule(parent: Router? = nil) -> SettingsViewController {
        let module = SettingsViewController()
        let router = SettingsRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol SettingsRoute {
    func openSettings()
}

extension SettingsRoute where Self: RouterProtocol {
    func openSettings() {
        let module = SettingsAssembly.createModule(parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
