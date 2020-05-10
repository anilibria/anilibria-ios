import UIKit

// MARK: - Router

protocol CommentsRoutable: BaseRoutable, CommentsAuthRoute {}

final class CommentsRouter: BaseRouter, CommentsRoutable {}
