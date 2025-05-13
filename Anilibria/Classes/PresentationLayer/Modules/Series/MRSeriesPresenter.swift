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

    private let mainService: MainService
    private let sessionService: SessionService
    private let favoriteService: FavoriteService
    private let collectionsService: UserCollectionsService
    private let downloadService: DownloadService

    private var favoriteState: Bool?
    private var collectionType: UserCollectionType?
    private var requestBag = Set<AnyCancellable>()
    private var updatesBag = Set<AnyCancellable>()
    private var isAutorized: Bool = false

    init(mainService: MainService,
         sessionService: SessionService,
         favoriteService: FavoriteService,
         downloadService: DownloadService,
         collectionsService: UserCollectionsService) {
        self.mainService = mainService
        self.sessionService = sessionService
        self.favoriteService = favoriteService
        self.downloadService = downloadService
        self.collectionsService = collectionsService
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
        self.favoriteService.favoritesUpdates().sink { [weak self] update in
            switch update {
            case .added(let series) where series.id == self?.series.id:
                self?.updateFavoriteState(true)
            case .deleted(let series) where series.id == self?.series.id:
                self?.updateFavoriteState(false)
            default: break
            }
        }
        .store(in: &updatesBag)

        self.collectionsService.collectionsUpdates().sink { [weak self] update in
            switch update {
            case .added(let series, let toType, _) where series.id == self?.series.id:
                self?.updateCollection(toType)
            case .deleted(let series, _) where series.id == self?.series.id:
                self?.updateCollection(nil)
            default: break
            }
        }
        .store(in: &updatesBag)

        self.mainService.fetchFranchise(for: series.id).sink(onNext: { [weak self] franchises in
            guard let self else { return }
            let items = franchises.flatMap { $0.releases.compactMap { $0.series } }
            view.set(series: items, current: series)
        }, onError: { [weak self] _ in
            guard let self else { return }
            view.set(series: [], current: series)
        }).store(in: &updatesBag)

        self.sessionService.fetchState().sink { [weak self] state in
            switch state {
            case .user: self?.isAutorized = true
            default: self?.isAutorized = false
            }

            self?.load(self?.view.showUpdatesActivity())
        }.store(in: &updatesBag)
    }

    func refresh() {
        load(view.showRefreshIndicator())
    }

    func select(genre: String) {
        guard let genreID = Int(genre) else { return }
        var data = SeriesSearchData()
        data.filter.genres = [genreID]

        self.router.openCatalog(data: data)
    }

    func select(url: URL) {
        self.router.open(url: .web(url))
    }

    func select(series: Series) {
        if series.id != self.series.id {
            router.open(series: series)
        }
    }

    func favorite(_ activity: (any ActivityDisposable)?) {
        guard let favoriteState else { return }
        if !isAutorized {
            router.signInScreen()
            return
        }
        favoriteService.favorite(add: !favoriteState, series: series)
            .manageActivity(activity)
            .sink(onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &requestBag)
    }

    func selectCollection(_ activity: (any ActivityDisposable)?) {
        if !isAutorized {
            router.signInScreen()
            return
        }

        let didSelect: (UserCollectionType) -> Bool = { [weak self] item in
            guard let self else { return true }
            if collectionType == item {
                collectionsService.removeFrom(collection: item, series: series)
                    .manageActivity(activity)
                    .sink(onError: { [weak self] error in
                        self?.router.show(error: error)
                    })
                    .store(in: &requestBag)
            } else {
                collectionsService.move(series: series, from: collectionType, to: item)
                    .manageActivity(activity)
                    .sink(onError: { [weak self] error in
                        self?.router.show(error: error)
                    })
                    .store(in: &requestBag)
            }
            return true
        }

        let items = UserCollectionType.allCases.map { item in
            ChoiceItem(
                value: item,
                title: item.localizedTitle,
                isSelected: item == collectionType,
                didSelect: didSelect
            )
        }

        router.openSheet(with: [ChoiceGroup(items: items)])
    }

    private func updateFavoriteState(_ newState: Bool) {
        self.favoriteState = newState
        view.set(favorite: newState)
    }

    private func updateCollection(_ type: UserCollectionType?) {
        self.collectionType = type
        view.set(collection: type)
    }

    func donate() {
        self.router.open(url: .web(URLS.donate))
    }

    private func load(_ activity: (any ActivityDisposable)? = nil) {
        requestBag.removeAll()

        Publishers.CombineLatest3(
            mainService.series(with: series.id),
            isAutorized ? favoriteService.getFavoriteState(for: series.id) : .just(false),
            isAutorized ? collectionsService.getCollection(for: series.id) : .just(nil)
        )
        .manageActivity(activity)
        .sink { [weak self] item, state, collection in
            guard let self else { return }
            series = item
            view.set(series: item)
            view.can(watch: item.playlist.isEmpty == false)
            updateFavoriteState(state)
            updateCollection(collection)
        } onError: { [weak self] error in
            self?.router.show(error: error)
        }
        .store(in: &requestBag)
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
            .store(in: &requestBag)
    }

    func share() {
        if let url = URLHelper.releaseUrl(self.series) {
            self.router.openShare(items: [url])
        }
    }
}

public struct ScheduleCommand: RouteCommand {}
