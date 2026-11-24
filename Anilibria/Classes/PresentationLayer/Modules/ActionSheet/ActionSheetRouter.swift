import UIKit

// MARK: - Router

protocol ActionSheetRoutable: BaseRoutable, BackRoute {}

final class ActionSheetRouter: BaseRouter, ActionSheetRoutable {}
