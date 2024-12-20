import DITranquillity
import Combine
import UIKit

final class SettingsPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SettingsPresenter.init)
            .as(SettingsEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SettingsPresenter {
    private weak var view: SettingsViewBehavior!
    private var router: SettingsRoutable!
    private var playerSettings: PlayerSettings

    private let playerService: PlayerService
    private let sessionService: SessionService

    private var bag = Set<AnyCancellable>()

    init(playerService: PlayerService,
         sessionService: SessionService) {
        self.playerService = playerService
        self.sessionService = sessionService
        self.playerSettings = playerService.fetchSettings()
    }
}

extension SettingsPresenter: SettingsEventHandler {
    func bind(view: SettingsViewBehavior,
              router: SettingsRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.view.set(quality: self.playerSettings.quality)
        self.view.set(language: Language.current)
        self.view.set(appearance: InterfaceAppearance.current)
        self.view.set(name: Bundle.main.displayName ?? "",
                      version: Bundle.main.releaseVersionNumber ?? "")

        Language.languageChanged.sink { [weak self] in
            self?.view.set(appearance: InterfaceAppearance.current)
        }.store(in: &bag)
    }

    func selectQuality() {
        let qualities = VideoQuality.allCases

        let items = qualities.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: playerSettings.quality == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }
    
    func selectLanguage() {
        let languages = Language.allCases
        let items = languages.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: Language.current == $0,
                didSelect: { [weak self] language in
                    Language.current = language
                    self?.view.set(language: language)
                    return true
                }
            )
        }
        
        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectAppearance() {
        let current = InterfaceAppearance.current
        let items = InterfaceAppearance.allCases.map {
            ChoiceItem(
                value: $0,
                title: $0.title,
                isSelected: current == $0,
                didSelect: { [weak self] item in
                    item.save()
                    item.apply()
                    self?.view.set(appearance: item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    private func update(_ quality: VideoQuality) {
        self.playerSettings.quality = quality
        self.playerService.update(settings: self.playerSettings)
        self.view.set(quality: quality)
    }
}
