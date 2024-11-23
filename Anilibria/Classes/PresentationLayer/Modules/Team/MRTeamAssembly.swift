import UIKit

final class TeamAssembly {
    class func createModule(parent: Router? = nil) -> TeamViewController {
        let module = TeamViewController()
        let router = TeamRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol TeamRoute {
    func openTeam()
}

extension TeamRoute where Self: RouterProtocol {
    func openTeam() {
        let module = TeamAssembly.createModule(parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
