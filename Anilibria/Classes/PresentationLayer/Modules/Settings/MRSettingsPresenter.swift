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
        self.view.set(audio: self.playerSettings.audioTrack.title)
        self.view.set(subtitle: self.playerSettings.subtitleTrack.title)
        self.view.set(name: Bundle.main.displayName ?? "",
                      version: Bundle.main.releaseVersionNumber ?? "")
    }

    func selectQuality() {
        let qualities = VideoQuality.allCases
        
        let items = qualities.compactMap { value -> ChoiceItem? in
            guard let name = value.name else { return nil }
            return ChoiceItem(value, title: name, isSelected: playerSettings.quality == value)
        }
        
        let group = ChoiceGroup(title: L10n.Common.quality, items: items)
        
        group.choiceCompleted = { [weak self] value in
            if let quality = value as? VideoQuality {
                self?.update(quality)
            }
        }
        
        self.router.openSheet(with: [group])
    }
    
    func selectAudio() {
        let items = AudioTrack.defaultList.map { value -> ChoiceItem in
            return ChoiceItem(value, title: value.title, isSelected: playerSettings.audioTrack == value)
        }
        
        let group = ChoiceGroup(title: L10n.Common.audioTrack, items: items)
        
        group.choiceCompleted = { [weak self] value in
            if let quality = value as? AudioTrack {
                self?.update(quality)
            }
        }
        
        self.router.openSheet(with: [group])
    }
    
    func selectSubtitle() {
        let items = Subtitles.defaultList.map { value -> ChoiceItem in
            return ChoiceItem(value, title: value.title, isSelected: playerSettings.subtitleTrack == value)
        }
        
        let group = ChoiceGroup(title: L10n.Common.sublitleTrack, items: items)
        
        group.choiceCompleted = { [weak self] value in
            if let quality = value as? Subtitles {
                self?.update(quality)
            }
        }
        
        self.router.openSheet(with: [group])
    }

    private func update(_ quality: VideoQuality) {
        if playerSettings.quality == quality { return }
        self.playerSettings.quality = quality
        self.playerService.update(settings: self.playerSettings)
        self.view.set(quality: quality)
    }
    
    private func update(_ audio: AudioTrack) {
        if playerSettings.audioTrack == audio { return }
        self.playerSettings.audioTrack = audio
        self.playerService.update(settings: self.playerSettings)
        self.view.set(audio: audio.title)
    }
    
    private func update(_ subtitle: Subtitles) {
        if playerSettings.subtitleTrack == subtitle { return }
        self.playerSettings.subtitleTrack = subtitle
        self.playerService.update(settings: self.playerSettings)
        self.view.set(subtitle: subtitle.title)
    }
}
