import UIKit

final class CommentsAuthAssembly {
    class func createModule(parent: Router? = nil) -> CommentsAuthViewController {
        let module = CommentsAuthViewController()
        let router = CommentsAuthRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol CommentsAuthRoute {}

extension CommentsAuthRoute where Self: RouterProtocol {
    func commentsAuth() {
        let module = CommentsAuthAssembly.createModule(parent: self)
        let nc = BaseNavigationController(rootViewController: module)
        ModalRouter(target: nc, parent: nil).move()
    }
}
