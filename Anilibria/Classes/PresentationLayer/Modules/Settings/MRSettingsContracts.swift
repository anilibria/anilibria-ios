import UIKit

// MARK: - Contracts

protocol SettingsViewBehavior: AnyObject {
    func set(name: String, version: String)
    func set(quality: VideoQuality)
    func set(language: Language)
    func set(appearance: InterfaceAppearance)
}

protocol SettingsEventHandler: ViewControllerEventHandler {
    func bind(view: SettingsViewBehavior, router: SettingsRoutable)

    func selectQuality()
    func selectLanguage()
    func selectAppearance()
}
