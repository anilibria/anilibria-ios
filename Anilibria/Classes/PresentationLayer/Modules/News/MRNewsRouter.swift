import UIKit

// MARK: - Router

protocol NewsRoutable: BaseRoutable, AppUrlRoute {}

final class NewsRouter: BaseRouter, NewsRoutable {}
