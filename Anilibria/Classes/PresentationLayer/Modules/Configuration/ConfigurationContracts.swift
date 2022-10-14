import UIKit

// MARK: - Contracts

protocol ConfigurationViewBehavior: AnyObject {}

protocol ConfigurationEventHandler: ViewControllerEventHandler {
    func bind(view: ConfigurationViewBehavior, router: ConfigurationRoutable)
}
