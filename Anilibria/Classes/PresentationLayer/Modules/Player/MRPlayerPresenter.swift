import DITranquillity
import Combine
import UIKit

final class PlayerPart: DIPart {
    static func load(container: DIContainer) {
        container.register(PlayerPresenter.init)
            .as(PlayerEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class PlayerPresenter {
    private weak var view: PlayerViewBehavior!
    private var router: PlayerRoutable!
    private var series: Series!
    private var playlist: [PlaylistItem] = []
    private var bag = Set<AnyCancellable>()
    
    private var currentSubtitle: Subtitles?
    private var availableSubtitles: [Subtitles] = []
    
    private var currentAudio: AudioTrack?
    private var availableAudioTracks: [AudioTrack] = []
    
    private let playerService: PlayerService

    init(playerService: PlayerService) {
        self.playerService = playerService
    }
}

extension PlayerPresenter: PlayerEventHandler {
    func bind(view: PlayerViewBehavior,
              router: PlayerRoutable,
              series: Series,
              playlist: [PlaylistItem]?) {
        self.view = view
        self.router = router
        self.series = series
        self.playlist = playlist ?? self.series.playlist.reversed()
    }

    func didLoad() {
        self.playerService
            .fetchPlayerContext(for: self.series)
            .sink(onNext: { [weak self] context in
                self?.run(with: context)
            })
            .store(in: &bag)
    }
    
    func set(currentSubtitle: Subtitles?, availableSubtitles: [Subtitles]) {
        self.currentSubtitle = currentSubtitle
        self.availableSubtitles = availableSubtitles
    }
    
    func set(currentAudio: AudioTrack?, availableAudioTracks: [AudioTrack]) {
        self.currentAudio = currentAudio
        self.availableAudioTracks = availableAudioTracks
    }

    func select(playItemIndex: Int) {
        let items = self.playlist.enumerated().map { value in
            ChoiceItem(value.offset,
                       title: value.element.title,
                       isSelected: value.offset == playItemIndex)
        }
        
        let group = ChoiceGroup(items: items)
        group.choiceCompleted = { [weak self] value in
            if let index = value as? Int, index != playItemIndex {
                self?.view.set(playItemIndex: index)
            }
        }
        
        self.router.openSheet(with: [group])
    }

    func settings(quality: VideoQuality?, for item: PlaylistItem) {
        let qualities = item.supportedQualities()
        let items = qualities.compactMap { value -> ChoiceItem? in
            guard let name = value.name else { return nil }
            return ChoiceItem(value, title: name, isSelected: quality == value)
        }
        
        var groups: [ChoiceGroup] = []

        if !items.isEmpty {
            let group = ChoiceGroup(title: L10n.Common.quality, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selectedQuality = value as? VideoQuality, selectedQuality != quality {
                    self?.view.set(quality: selectedQuality)
                }
            }
            
            groups.append(group)
        }
        
        if !availableAudioTracks.isEmpty {
            let items = availableAudioTracks.map { value -> ChoiceItem in
                return ChoiceItem(value, title: value.title, isSelected: currentAudio == value)
            }
            
            let group = ChoiceGroup(title: L10n.Common.audioTrack, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selected = value as? AudioTrack, self?.currentAudio != selected {
                    self?.currentAudio = selected
                    self?.view.set(audio: selected)
                }
            }
            
            groups.append(group)
        }
        
        if !availableSubtitles.isEmpty {
            let items = availableSubtitles.map { value -> ChoiceItem in
                return ChoiceItem(value, title: value.title, isSelected: currentSubtitle == value)
            }
            
            let group = ChoiceGroup(title: L10n.Common.sublitleTrack, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selected = value as? Subtitles, self?.currentSubtitle != selected {
                    self?.currentSubtitle = selected
                    self?.view.set(subtitle: selected)
                }
            }
            
            groups.append(group)
        }
        
        self.router.openSheet(with: groups)
    }

    func back() {
        self.router.back()
    }

    func save(quality: VideoQuality?, number: Int, time: Double) {
        let context = PlayerContext(quality: quality,
                                    audioTrack: currentAudio,
                                    subtitleTrack: currentSubtitle,
                                    number: number,
                                    time: time)
        self.playerService
            .set(context: context, for: self.series)
            .sink()
            .store(in: &bag)
    }

    private func run(with context: PlayerContext?) {
        let index = context?.number ?? 0
        let settings = self.playerService.fetchSettings()
        let preffered = PrefferedSettings(
            quality: context?.quality ?? settings.quality,
            audioTrack: context?.audioTrack ?? settings.audioTrack,
            subtitleTrack: context?.subtitleTrack ?? settings.subtitleTrack
        )

        self.view.set(name: self.series.names.first ?? "",
                      playlist: self.playlist,
                      playItemIndex: index,
                      time: Double(context?.time ?? 0),
                      preffered: preffered)
    }
}
