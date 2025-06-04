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

    private var playerSettings: PlayerSettings?

    private let playerService: PlayerService
    private let sessionService: SessionService

    private var bag = Set<AnyCancellable>()

    init(playerService: PlayerService,
         sessionService: SessionService) {
        self.playerService = playerService
        self.sessionService = sessionService
    }
}

extension SettingsPresenter: SettingsEventHandler {
    func bind(view: SettingsViewBehavior,
              router: SettingsRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        bag.removeAll()
        var items: [SettingsControlItem] = []
        let languageItem = SettingsControlItem(
            title: L10n.Screen.Settings.language,
            value: Language.current.name,
            action: { [weak self] _ in self?.selectLanguage() }
        )
        items.append(languageItem)

        let qualityItem = SettingsControlItem(
            title: L10n.Screen.Settings.videoQuality,
            value: "",
            action: { [weak self] _ in self?.selectQuality() }
        )
        items.append(qualityItem)

        let speedItem = SettingsControlItem(
            title: L10n.Common.playbackRate,
            value: "",
            action: { [weak self] _ in self?.selectPlaybackRate() }
        )
        items.append(speedItem)

        let skipItem = SettingsControlItem(
            title: L10n.Common.skipCredits,
            value: "",
            action: { [weak self] _ in self?.selectSkipMode() }
        )
        items.append(skipItem)

        let autoplayItem = SettingsControlItem(
            title: L10n.Common.autoPlay,
            value: "",
            action: { [weak self] _ in self?.selectAutoplay() }
        )
        items.append(autoplayItem)

        let appearanceItem = SettingsControlItem(
            title: L10n.Common.appearance,
            value: InterfaceAppearance.current.title,
            action: { [weak self] in self?.selectAppearance($0) }
        )
        items.append(appearanceItem)

        if UIDevice.current.userInterfaceIdiom == .phone {
            let orientation = SettingsControlItem(
                title: L10n.Common.orientation,
                value: InterfaceOrientation.current.title,
                action: { [weak self] in self?.selectOrientation($0) }
            )
            items.append(orientation)
        }

        playerService.observeSettings().sink { [weak self] settings in
            self?.playerSettings = settings
            qualityItem.value = settings.quality.name
            speedItem.value = PlayerSettings.nameFor(rate: settings.playbackRate)
            autoplayItem.value = PlayerSettings.nameFor(autoPlay: settings.autoPlay)
            skipItem.value = settings.skipMode.name
        }.store(in: &bag)

        self.view.set(name: Bundle.main.displayName ?? "",
                      version: Bundle.main.releaseVersionNumber ?? "")
        self.view.set(common: items)
    }

    func selectQuality() {
        let qualities = VideoQuality.allCases

        let items = qualities.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: playerSettings?.quality == $0,
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
                didSelect: { language in
                    Language.current = language
                    return true
                }
            )
        }
        
        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectAppearance(_ control: SettingsControlItem) {
        let current = InterfaceAppearance.current
        let items = InterfaceAppearance.allCases.map {
            ChoiceItem(
                value: $0,
                title: $0.title,
                isSelected: current == $0,
                didSelect: { item in
                    item.save()
                    item.apply()
                    control.value = item.title
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectOrientation(_ control: SettingsControlItem) {
        let current = InterfaceOrientation.current
        let items = InterfaceOrientation.allCases.map {
            ChoiceItem(
                value: $0,
                title: $0.title,
                isSelected: current == $0,
                didSelect: { item in
                    item.save()
                    control.value = item.title
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectPlaybackRate() {
        let options = PlayerSettings.playbackRateOptions

        let items = options.map {
            ChoiceItem(
                value: $0,
                title: "\($0)x",
                isSelected: playerSettings?.playbackRate == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectSkipMode() {
        let options = SkipCreditsMode.allCases

        let items = options.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: playerSettings?.skipMode == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func selectAutoplay() {
        let items = [true, false].map {
            ChoiceItem(
                value: $0,
                title: PlayerSettings.nameFor(autoPlay: $0),
                isSelected: playerSettings?.autoPlay == $0,
                didSelect: { [weak self] item in
                    self?.update(item)
                    return true
                }
            )
        }
        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    private func update(_ quality: VideoQuality) {
        guard var playerSettings else { return }
        playerSettings.quality = quality
        playerService.update(settings: playerSettings)
    }

    private func update(_ rate: Double) {
        guard var playerSettings else { return }
        playerSettings.playbackRate = rate
        playerService.update(settings: playerSettings)
    }

    private func update(_ mode: SkipCreditsMode) {
        guard var playerSettings else { return }
        playerSettings.skipMode = mode
        playerService.update(settings: playerSettings)
    }

    private func update(_ autoplay: Bool) {
        guard var playerSettings else { return }
        playerSettings.autoPlay = autoplay
        playerService.update(settings: playerSettings)
    }
}
