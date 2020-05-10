import UIKit

// MARK: - Router

protocol ChoiceSheetRoutable: BaseRoutable, BackRoute {}

final class ChoiceSheetRouter: BaseRouter, ChoiceSheetRoutable {}
