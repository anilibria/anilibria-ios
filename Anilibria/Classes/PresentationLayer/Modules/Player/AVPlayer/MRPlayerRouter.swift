import UIKit

// MARK: - Router

protocol PlayerRoutable: BaseRoutable, BackRoute, ChoiceSheetRoute {}

final class PlayerRouter: BaseRouter, PlayerRoutable {}
