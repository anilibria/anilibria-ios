import UIKit

// MARK: - Router

protocol FilterRoutable: BaseRoutable, BackRoute {}

final class FilterRouter: BaseRouter, FilterRoutable {}
