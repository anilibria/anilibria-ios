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
    }

    func didLoad() {
        bag.removeAll()
        self.view.set(series: self.series)
        self.view.set(favorite: self.series.favorite?.added ?? false,
                      count: self.series.favorite?.rating ?? 0)

        self.view.can(watch: self.series.playlist.isEmpty == false)
        self.sessionService
            .fetchState()
            .sink(onNext: { [weak self] state in
                switch state {
                case .guest:
                    self?.view.can(favorite: false)
                case .user:
                    self?.view.can(favorite: true)
                }
            })
            .store(in: &bag)
    }

    func select(genre: String) {
        var filter = SeriesFilter()
        filter.genres = [genre]
        let command = FilterRouteCommand(value: filter)
        self.router.execute(command)
    }

    func select(url: URL) {
        if let code = URLHelper.isRelease(url: url) {
            self.load(code: code)
        } else {
            self.router.open(url: .web(url))
        }
    }

    func favorite() {
        if let favorite = self.series.favorite {
            let added = !favorite.added
            let command = FavoriteCommand(added: added,
                                          value: self.series)
            self.favoriteService
                .favorite(add: added, series: self.series)
                .manageActivity(self.view.showLoading(fullscreen: false))
                .sink(onNext: { [weak self] _ in
                    favorite.added = added
                    let value = added ? 1 : -1
                    favorite.rating += value
                    self?.view.set(favorite: added, count: favorite.rating)
                    self?.router.execute(command)
                }, onError: { [weak self] error in
                    self?.router.show(error: error)
                })
                .store(in: &bag)
        }
    }

    func donate() {
        self.router.execute(UrlCommand(url: URLS.donate))
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
        var name = self.series.names.last ?? self.series.code
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

public struct UrlCommand: RouteCommand {
    let url: URL?
}
