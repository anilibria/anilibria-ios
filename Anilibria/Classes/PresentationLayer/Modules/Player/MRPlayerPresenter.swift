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

extension PlayerPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let command = command as? ChoiceResult {
            if let value = command.value as? PlaylistItem,
                let index = self.playlist.firstIndex(of: value) {
                self.view.set(playItemIndex: index)
                return true
            }
            if let value = command.value as? VideoQuality {
                self.view.set(quality: value)
                return true
            }
        }
        return false
    }
}

extension PlayerPresenter: PlayerEventHandler {
    func bind(view: PlayerViewBehavior,
              router: PlayerRoutable,
              series: Series,
              playlist: [PlaylistItem]?) {
        self.view = view
        self.router = router
        self.router.responder = self
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
        let lastIndex = self.playlist.count - 1
        let items = self.playlist.enumerated().map { value in
            ChoiceItem(value.element,
                       title: value.element.title,
                       isSelected: value.offset == playItemIndex,
                       isLast: value.offset == lastIndex)
        }
        
        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func settings(quality: VideoQuality?, for item: PlaylistItem) {
        let qualities = item.supportedQualities()
        let items = qualities.compactMap { value -> ChoiceItem? in
            guard let name = value.name else { return nil }
            return ChoiceItem(value, title: name, isSelected: quality == value,
                              isLast: qualities.last == value)
        }

        if !items.isEmpty {
            self.router.openSheet(with: [ChoiceGroup(title: L10n.Common.quality, items: items)])
        }
    }

    func back() {
        self.router.back()
    }

    func save(quality: VideoQuality?, number: Int, time: Double) {
        let context = PlayerContext(quality: quality,
                                    number: number,
                                    time: time)
        self.playerService
            .set(context: context, for: self.series)
            .sink()
            .store(in: &bag)
    }

    private func run(with context: PlayerContext?) {
        let index = context?.number ?? 0
        let settingsQuality = self.playerService.fetchSettings().quality
        let prefferedQualities: VideoQuality = context?.quality ?? settingsQuality

        self.view.set(name: self.series.names.first ?? "",
                      playlist: self.playlist,
                      playItemIndex: index,
                      time: Double(context?.time ?? 0),
                      preffered: prefferedQualities)
    }
}
