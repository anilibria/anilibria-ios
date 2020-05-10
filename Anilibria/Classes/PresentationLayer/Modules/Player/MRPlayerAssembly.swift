import UIKit

final class PlayerAssembly {
    class func createModule(series: Series, parent: Router? = nil) -> PlayerViewController {
        let module = PlayerViewController()
        let router = PlayerRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, series: series)
        return module
    }
}

// MARK: - Route

protocol PlayerRoute {
    func openPlayer(series: Series)
}

extension PlayerRoute where Self: RouterProtocol {
    func openPlayer(series: Series) {
        let module = PlayerAssembly.createModule(series: series, parent: self)
        ModalRouter(target: module, parent: nil)
            .set(level: .statusBar)
            .move()
    }
}
