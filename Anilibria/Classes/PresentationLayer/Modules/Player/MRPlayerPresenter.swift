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
    private var selectedOrientation = InterfaceOrientation.current

    private let playerService: PlayerService

    init(playerService: PlayerService) {
        self.playerService = playerService
    }
}

extension PlayerPresenter: PlayerEventHandler {
    func bind(view: PlayerViewBehavior,
              router: PlayerRoutable,
              series: Series) {
        self.view = view
        self.router = router
        self.series = series
        self.playlist = self.series.playlist.reversed()
    }

    func didLoad() {
        self.view.set(orientation: selectedOrientation)
        self.playerService
            .fetchPlayerContext(for: self.series)
            .sink(onNext: { [weak self] context in
                self?.run(with: context)
            })
            .store(in: &bag)
    }

    func select(playItemIndex: Int) {
        let didSelect: (PlaylistItem) -> Bool = { [weak self] item in
            guard let index = self?.playlist.firstIndex(of: item) else { return true }
            self?.view.set(playItemIndex: index)
            return true
        }

        let items = self.playlist.enumerated().map { value in
            ChoiceItem(
                value: value.element,
                title: value.element.fullName,
                isSelected: value.offset == playItemIndex,
                didSelect: didSelect
            )
        }

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    func settings(quality: VideoQuality, for item: PlaylistItem) {
        var groups: [ChoiceGroup] = []

        if UIDevice.current.userInterfaceIdiom == .phone {
            let didSelectOrientation: (InterfaceOrientation) -> Bool = { [weak self] item in
                self?.selectedOrientation = item
                item.save()
                self?.view.set(orientation: item)
                return false
            }

            let orientations = InterfaceOrientation.allCases

            let orientationItems = orientations.map {
                ChoiceItem(
                    value: $0,
                    title: $0.title, isSelected: selectedOrientation == $0,
                    didSelect: didSelectOrientation
                )
            }

            groups.append(ChoiceGroup(title: L10n.Common.orientation, items: orientationItems))
        }

        let didSelect: (VideoQuality) -> Bool = { [weak self] item in
            self?.view.set(quality: item)
            return false
        }

        let qualities = item.supportedQualities()
        let items = qualities.map {
            ChoiceItem(
                value: $0,
                title: $0.name, isSelected: quality == $0,
                didSelect: didSelect
            )
        }

        groups.append(ChoiceGroup(title: L10n.Common.quality, items: items))

        self.router.openSheet(with: groups)
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
            .sink()
            .store(in: &bag)
    }

    private func run(with context: PlayerContext?) {
        let index = context?.number ?? 0
        let settingsQuality = self.playerService.fetchSettings().quality
        let prefferedQualities: VideoQuality = context?.quality ?? settingsQuality

        self.view.set(name: self.series.name?.main ?? "",
                      playlist: self.playlist,
                      playItemIndex: index,
                      time: Double(context?.time ?? 0),
                      preffered: prefferedQualities)
    }
}


extension UIInterfaceOrientationMask {
    var name: String {
        switch self {
        case .portrait: return L10n.Common.Orientation.portrait
        case .landscapeLeft: return L10n.Common.Orientation.landscape
        case .all: return L10n.Common.Orientation.system
        default: return ""
        }
    }
}
