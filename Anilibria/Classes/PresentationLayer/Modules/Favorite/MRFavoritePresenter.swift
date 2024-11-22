import DITranquillity
import Combine
import UIKit

final class FavoritePart: DIPart {
    static func load(container: DIContainer) {
        container.register(FavoritePresenter.init)
            .as(FavoriteEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class FavoritePresenter {
    private weak var view: FavoriteViewBehavior!
    private var router: FavoriteRoutable!
    private var bag = Set<AnyCancellable>()

    let favoriteService: FavoriteService
    let feedService: FeedService

    let viewModel: FavoriteViewModel

    init(favoriteService: FavoriteService,
         feedService: FeedService) {
        self.favoriteService = favoriteService
        self.feedService = feedService
        self.viewModel = FavoriteViewModel(service: favoriteService)

        viewModel.select = { [weak self] item in
            self?.view.seriesSelected()
            self?.select(series: item)
        }

        viewModel.delete = { [weak self] item in
            self?.unfavorite(series: item)
        }

        favoriteService.favoritesUpdates().sink { [weak self] updates in
            switch updates {
            case .added(let series):
                self?.viewModel.append(series: series)
            case .deleted(let series):
                self?.viewModel.remove(series: series)
            }
        }.store(in: &bag)
    }
}

extension FavoritePresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let filterCommand = command as? FilterRouteCommand {
            if viewModel.filter != filterCommand.value {
                self.update(filter: filterCommand.value)
            }
            return true
        }
        return false
    }
}

extension FavoritePresenter: FavoriteEventHandler {
    func bind(view: FavoriteViewBehavior, router: FavoriteRoutable) {
        self.view = view
        self.router = router
        self.router.responder = self
        viewModel.router = router
    }

    func didLoad() {
        self.view.set(model: viewModel)
        self.load(with: self.view.showLoading(fullscreen: false))
    }

    func refresh() {
        self.load(with: self.view.showRefreshIndicator())
    }

    func search(query: String) {
        viewModel.filter.search = query.lowercased()
        refresh()
    }

    func openFilter() {
        self.favoriteService.fetchFilterData()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] data in
                guard let self else { return }
                router.open(filter: viewModel.filter, data: data)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func unfavorite(series: Series) {
        self.favoriteService
            .favorite(add: false, series: series)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] _ in
                self?.viewModel.remove(series: series)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func select(series: Series) {
        self.feedService.series(with: series.alias)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    private func load(with activity: ActivityDisposable?) {
        viewModel.load(activity: activity)
    }

    private func update(filter: SeriesFilter) {
        view.scrollToTop()
        viewModel.filter = filter
        view.setFilter(active: viewModel.filter != SeriesFilter())
        refresh()
    }
}
