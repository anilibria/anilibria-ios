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

extension SettingsPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let quality = (command as? ChoiceResult)?.value as? VideoQuality {
            self.update(quality)
            return true
        }
        return false
    }
}

extension SettingsPresenter: SettingsEventHandler {
    func bind(view: SettingsViewBehavior,
              router: SettingsRoutable) {
        self.view = view
        self.router = router
        self.router.responder = self
    }

    func didLoad() {
        self.view.set(quality: self.playerSettings.quality)
        self.view.set(name: Bundle.main.displayName ?? "",
                      version: Bundle.main.releaseVersionNumber ?? "")
    }

    func selectQuality() {
        let qualities = VideoQuality.allCases
        
        let items = qualities.compactMap { value -> ChoiceItem? in
            guard let name = value.name else { return nil }
            return ChoiceItem(value, title: name, isSelected: playerSettings.quality == value,
                              isLast: qualities.last == value)
        }
        
        self.router.openSheet(with: [ChoiceGroup(title: L10n.Common.quality, items: items)])
    }

    private func update(_ quality: VideoQuality) {
        self.playerSettings.quality = quality
        self.playerService.update(settings: self.playerSettings)
        self.view.set(quality: quality)
    }
}
