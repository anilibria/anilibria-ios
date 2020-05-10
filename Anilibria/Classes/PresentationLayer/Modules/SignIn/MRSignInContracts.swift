import UIKit

// MARK: - Contracts

protocol SignInViewBehavior: WaitingBehavior {
    func set(socialLogin avaible: Bool)
}

protocol SignInEventHandler: ViewControllerEventHandler {
    func bind(view: SignInViewBehavior, router: SignInRoutable)

    func back()
    func register()

    func login(login: String, password: String, code: String)
    func socialLogin()
}
