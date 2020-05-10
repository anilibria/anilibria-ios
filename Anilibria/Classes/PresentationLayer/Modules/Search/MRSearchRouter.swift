import UIKit

// MARK: - Router

protocol SearchRoutable: BaseRoutable, BackRoute {}

final class SearchRouter: BaseRouter, SearchRoutable {}
