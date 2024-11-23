import UIKit

// MARK: - Router

protocol SignInRoutable: BaseRoutable, BackRoute, SafariRoute {}

final class SignInRouter: BaseRouter, SignInRoutable {}
