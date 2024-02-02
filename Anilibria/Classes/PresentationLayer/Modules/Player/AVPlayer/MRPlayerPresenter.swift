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
            let group = ChoiceGroup(title: L10n.Screen.Settings.videoQuality, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selectedQuality = value as? VideoQuality, selectedQuality != quality {
                    self?.view.set(quality: selectedQuality)
                }
            }
            
            groups.append(group)
        }
        
        self.router.openSheet(with: groups)
    }

    func back() {
        self.router.back()
    }

    func save(quality: VideoQuality?, id: Int, time: Double) {
        let context = PlayerContext(id: id,
                                    time: time,
                                    quality: quality)
        self.playerService
            .set(context: context, for: self.series)
            .sink()
            .store(in: &bag)
    }

    private func run(with context: PlayerContext?) {
        let settings = self.playerService.fetchSettings()
        let preffered = PrefferedSettings(
            quality: context?.quality ?? settings.quality,
            audioTrack: settings.audioTrack,
            subtitleTrack: settings.subtitleTrack
        )
        
        var index = context?.number ?? 0
        
        if let id = context?.id, index == 0 {
            index = playlist.firstIndex(where: { $0.id == id }) ?? 0
        }
        
        self.view.set(name: self.series.names.first ?? "",
                      playlist: self.playlist,
                      playItemIndex: index,
                      time: Double(context?.time ?? 0),
                      preffered: preffered)
    }
}
