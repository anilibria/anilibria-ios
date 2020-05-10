import UIKit

// MARK: - Router

protocol CommentsAuthRoutable: BaseRoutable, BackRoute {}

final class CommentsAuthRouter: BaseRouter, CommentsAuthRoutable {}
