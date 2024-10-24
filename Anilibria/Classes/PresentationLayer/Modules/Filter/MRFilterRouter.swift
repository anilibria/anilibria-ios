import UIKit

// MARK: - Router

protocol FilterRoutable: BaseRoutable, BackRoute, ChoiceSheetRoute {}

final class FilterRouter: BaseRouter, FilterRoutable {}
