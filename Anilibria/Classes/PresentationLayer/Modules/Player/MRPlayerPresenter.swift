import DITranquillity
import RxSwift
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
    private var bag: DisposeBag = DisposeBag()

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
              series: Series) {
        self.view = view
        self.router = router
        self.router.responder = self
        self.series = series
        self.playlist = self.series.playlist.reversed()
    }

    func didLoad() {
        self.playerService
            .fetchPlayerContext(for: self.series)
            .subscribe(onSuccess: { [weak self] context in
                self?.run(with: context)
            })
            .disposed(by: self.bag)
    }

    func select(playItemIndex: Int) {
        let items = self.playlist.enumerated().map { value in
            ChoiceItem(value.element,
                       title: value.element.title,
                       isSelected: value.offset == playItemIndex)
        }

        self.router.openSheet(with: items)
    }

    func settings(quality: VideoQuality, for item: PlaylistItem) {
        let items = item.supportedQualities().map {
            ChoiceItem($0, title: $0.name, isSelected: quality == $0)
        }

        self.router.openSheet(with: items)
    }

    func back() {
        self.router.back()
    }

    func save(quality: VideoQuality, number: Int, time: Double) {
        let context = PlayerContext(quality: quality,
                                    number: number,
                                    time: time)
        self.playerService
            .set(context: context, for: self.series)
            .subscribe()
            .disposed(by: self.bag)
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
