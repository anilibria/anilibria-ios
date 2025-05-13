import UIKit

final class HistoryAssembly {
    static func createModule(parent: Router? = nil) -> HistoryViewController {
        let module = HistoryViewController()
        let router = HistoryRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol HistoryRoute {
    func openHistory()
}

extension HistoryRoute where Self: RouterProtocol {
    func openHistory() {
        let module = HistoryAssembly.createModule(parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
