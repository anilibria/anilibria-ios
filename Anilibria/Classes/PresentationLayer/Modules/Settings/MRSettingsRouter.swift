import UIKit

// MARK: - Router

protocol SettingsRoutable: BaseRoutable, ChoiceSheetRoute, PermissionRoute {}

final class SettingsRouter: BaseRouter, SettingsRoutable {}
