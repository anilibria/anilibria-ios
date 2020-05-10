import UIKit

// MARK: - Router

protocol ConfigurationRoutable: BaseRoutable, AlertRoute {}

final class ConfigurationRouter: BaseRouter, ConfigurationRoutable {}
