import UIKit

final class SignInAssembly {
    class func createModule(parent: Router? = nil) -> SignInViewController {
        let module = SignInViewController()
        let router = SignInRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol SignInRoute {
    func signInScreen()
}

extension SignInRoute where Self: RouterProtocol {
    func signInScreen() {
        let module = SignInAssembly.createModule(parent: self)
        let nc = BaseNavigationController(rootViewController: module)
        if UIDevice.current.userInterfaceIdiom != .pad {
            nc.modalPresentationStyle = .overFullScreen
        }
        ModalRouter(target: nc, parent: controller).move()
    }
}
