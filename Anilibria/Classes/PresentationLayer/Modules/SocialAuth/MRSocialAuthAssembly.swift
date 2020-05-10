import UIKit

final class SocialAuthAssembly {
    class func createModule(with data: SocialOAuthData, parent: Router? = nil) -> SocialAuthViewController {
        let module = SocialAuthViewController()
        let router = SocialAuthRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, socialData: data)
        return module
    }
}

// MARK: - Route

protocol SocialAuthRoute {
    func socialAuth(with: SocialOAuthData)
}

extension SocialAuthRoute where Self: RouterProtocol {
    func socialAuth(with data: SocialOAuthData) {
        let module = SocialAuthAssembly.createModule(with: data, parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
