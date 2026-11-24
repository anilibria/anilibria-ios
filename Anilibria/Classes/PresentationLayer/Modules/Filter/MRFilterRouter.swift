import UIKit

// MARK: - Router

protocol FilterRoutable: BaseRoutable, BackRoute, ActionSheetRoute {}

final class FilterRouter: BaseRouter, FilterRoutable {}
