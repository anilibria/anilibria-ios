import UIKit

// MARK: - Router

protocol SocialAuthRoutable: BaseRoutable, BackRoute {}

final class SocialAuthRouter: BaseRouter, SocialAuthRoutable {}
