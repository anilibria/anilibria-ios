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
    private var notifySettings: NotifySettings

    private let playerService: PlayerService
    private let sessionService: SessionService
    private let notifyService: NotifyService

    private var bag = Set<AnyCancellable>()

    init(playerService: PlayerService,
         sessionService: SessionService,
         notifyService: NotifyService) {
        self.playerService = playerService
        self.sessionService = sessionService
        self.notifyService = notifyService
        self.notifySettings = notifyService.getSettings()
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
        self.view.set(global: self.notifySettings.global, animated: false)
        self.view.set(quality: self.playerSettings.quality)
        self.view.set(name: Bundle.main.displayName ?? "",
                      version: Bundle.main.releaseVersionNumber ?? "")
    }

    func selectQuality() {
        let qualities = VideoQuality.allCases

        let items = qualities.map {
            ChoiceItem($0, title: $0.name, isSelected: playerSettings.quality == $0)
        }

        self.router.openSheet(with: items)
    }

    func change(global: Bool) {
        self.router.request(permission: .push) { [weak self] result in
            if result {
                self?.notifySettings.global = global
                self?.notifyService.set(settings: self!.notifySettings)
            } else {
                self?.view.set(global: !global, animated: true)
            }
        }
    }

    private func update(_ quality: VideoQuality) {
        self.playerSettings.quality = quality
        self.playerService.update(settings: self.playerSettings)
        self.view.set(quality: quality)
    }
}
