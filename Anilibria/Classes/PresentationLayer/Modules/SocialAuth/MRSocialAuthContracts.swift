import UIKit

// MARK: - Contracts

protocol SocialAuthViewBehavior: WaitingBehavior {
    func set(url: URL)
}

protocol SocialAuthEventHandler: ViewControllerEventHandler {
    func bind(view: SocialAuthViewBehavior,
              router: SocialAuthRoutable,
              socialData: SocialOAuthData)

    func redirect(url: URL) -> Bool
    func back()
}
