import UIKit

// MARK: - Contracts

protocol ConfigurationViewBehavior: class {}

protocol ConfigurationEventHandler: ViewControllerEventHandler {
    func bind(view: ConfigurationViewBehavior, router: ConfigurationRoutable)
}
