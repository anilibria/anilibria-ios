import DITranquillity
import Combine
import UIKit

final class SeriesPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SeriesPresenter.init)
            .as(SeriesEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SeriesPresenter {
    private weak var view: SeriesViewBehavior!
    private var router: SeriesRoutable!
    private var series: Series!

    private let feedService: FeedService
    private let sessionService: SessionService
    private let favoriteService: FavoriteService
    private let downloadService: DownloadService

    private var favoriteState: Bool?
    private var favoritesCount: Int = 0
    private var bag = Set<AnyCancellable>()

    init(feedService: FeedService,
         sessionService: SessionService,
         favoriteService: FavoriteService,
         downloadService: DownloadService) {
        self.feedService = feedService
        self.sessionService = sessionService
        self.favoriteService = favoriteService
        self.downloadService = downloadService
    }
}

extension SeriesPresenter: SeriesEventHandler {
    func bind(view: SeriesViewBehavior,
              router: SeriesRoutable,
              series: Series) {
        self.view = view
        self.router = router
        self.series = series
        self.favoritesCount = series.addedInUsersFavorites
    }

    func didLoad() {
        bag.removeAll()
        self.view.set(series: self.series)
        self.view.set(favorite: favoriteState, count: favoritesCount)

        self.view.can(watch: self.series.playlist.isEmpty == false)
        self.sessionService
            .fetchState()
            .sink(onNext: { [weak self] state in
                guard let self else { return }
                switch state {
                case .guest, nil:
                    view.can(favorite: false)
                    view.set(favorite: favoriteState, count: favoritesCount)
                case .user:
                    view.can(favorite: true)
                    loadFavorite()
                }
            })
            .store(in: &bag)

        self.favoriteService.favoritesUpdates().sink { [weak self] update in
            switch update {
            case .added(let series) where series.id == self?.series.id:
                self?.updateFavoriteState(true)
            case .deleted(let series) where series.id == self?.series.id:
                self?.updateFavoriteState(false)
            default: break
            }
        }
        .store(in: &bag)
    }

    private func loadFavorite() {
        self.favoriteService.getFavoriteState(for: series.id).sink { [weak self] state in
            guard let self else { return }
            favoriteState = state
            view.set(favorite: state, count: favoritesCount)
        } onError: { [weak self] _ in
            self?.view.can(favorite: false)
        }
        .store(in: &bag)
    }

    func select(genre: String) {
        guard let genreID = Int(genre) else { return }
        var filter = SeriesFilter()
        filter.genres = [genreID]

        self.router.openCatalog(filter: filter)
    }

    func select(url: URL) {
        if let code = URLHelper.isRelease(url: url) {
            self.load(code: code)
        } else {
            self.router.open(url: .web(url))
        }
    }

    func favorite() {
        guard let favoriteState else { return }
        self.favoriteService
            .favorite(add: !favoriteState, series: series)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    private func updateFavoriteState(_ newState: Bool) {
        self.favoriteState = newState
        let value = newState ? 1 : -1
        favoritesCount += value
        view.set(favorite: newState, count: favoritesCount)
    }

    func donate() {
        self.router.open(url: .web(URLS.donate))
    }

    private func load(code: String) {
        self.feedService.series(with: code)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                self?.router.execute(SeriesCommand(value: item))
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func schedule() {
        self.router.execute(ScheduleCommand())
    }

    func back() {
        self.router.back()
    }

    func play() {
        self.router.openPlayer(series: self.series)
    }

    func download(torrent: Torrent) {
        var name = self.series.name?.english ?? ""
        if name.isEmpty {
            name = series.alias
        }
        name.removingRegexMatches(pattern: "[^A-Za-z0-9]+", replaceWith: "_")
        self.downloadService.download(torrent: torrent, fileName: name)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] in
                self?.router.openAlert(message: L10n.Screen.Series.downloaded(name, Constants.downloadFolder))
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func share() {
        if let url = URLHelper.releaseUrl(self.series) {
            self.router.openShare(items: [url])
        }
    }
}

public struct SeriesCommand: RouteCommand {
    let value: Series
}

public struct ScheduleCommand: RouteCommand {}
