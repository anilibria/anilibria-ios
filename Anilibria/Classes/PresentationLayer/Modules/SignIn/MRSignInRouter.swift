import UIKit

// MARK: - Router

protocol SignInRoutable: BaseRoutable, BackRoute, SafariRoute, AppUrlRoute, RestorePasswordRoute {}

final class SignInRouter: BaseRouter, SignInRoutable {}
