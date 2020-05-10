import UIKit

// MARK: - Router

protocol SignInRoutable: BaseRoutable, BackRoute, AppUrlRoute, SocialAuthRoute {}

final class SignInRouter: BaseRouter, SignInRoutable {}
