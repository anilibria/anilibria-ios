import UIKit

// MARK: - Router

protocol SettingsRoutable: BaseRoutable, ActionSheetRoute, PermissionRoute {}

final class SettingsRouter: BaseRouter, SettingsRoutable {}
