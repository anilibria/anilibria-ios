import UIKit

// MARK: - Contracts

protocol SettingsViewBehavior: class {
    func set(name: String, version: String)
    func set(quality: VideoQuality)
    func set(global: Bool, animated: Bool)
}

protocol SettingsEventHandler: ViewControllerEventHandler {
    func bind(view: SettingsViewBehavior, router: SettingsRoutable)

    func selectQuality()
    func change(global: Bool)
}
