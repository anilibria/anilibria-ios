import UIKit

// MARK: - Contracts

protocol SignInViewBehavior: WaitingBehavior {
    func set(providers: [AuthProvider])
}

protocol SignInEventHandler: ViewControllerEventHandler {
    func bind(view: SignInViewBehavior, router: SignInRoutable)

    func back()
    func cancel()

    func login(login: String, password: String)
    func login(with provider: AuthProvider)
}
