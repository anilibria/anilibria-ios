import DITranquillity
import Combine
import UIKit

final class CatalogPart: DIPart {
    static func load(container: DIContainer) {
        container.register(CatalogPresenter.init)
            .as(CatalogEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class CatalogPresenter {
    private weak var view: CatalogViewBehavior!
    private var router: CatalogRoutable!

    private let feedService: FeedService

    private var activity: ActivityDisposable?
    private var bag = Set<AnyCancellable>()
    private var filter: SeriesFilter = SeriesFilter()

    private lazy var paginator: Paginator = Paginator<Series, IntPaging>(IntPaging()) { [unowned self] in
        return self.feedService.fetchCatalog(page: $0, filter: self.filter)
    }

    init(feedService: FeedService) {
        self.feedService = feedService
    }
}

extension CatalogPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let filterCommand = command as? FilterRouteCommand {
            if self.filter != filterCommand.value {
                self.update(filter: filterCommand.value)
            }
            return true
        }

        if let searchCommand = command as? SearchResultCommand {
            switch searchCommand.value {
            case let .series(item):
                self.select(series: item)
            case let .google(query):
                self.router.open(url: .google(query))
            case .filter:
                break
            }
            return true
        }
        return false
    }
}

extension CatalogPresenter: CatalogEventHandler {
    func bind(view: CatalogViewBehavior,
              router: CatalogRoutable,
              filter: SeriesFilter) {
        self.view = view
        self.router = router
        self.filter = filter
        self.router.responder = self
    }

    func didLoad() {
        self.update(filter: self.filter)
        self.setupPaginator()
        self.activity = self.view.showLoading(fullscreen: false)
        self.paginator.refresh()
    }

    func refresh() {
        self.activity = self.view.showRefreshIndicator()
        self.paginator.refresh()
    }

    func loadMore() {
        self.paginator.loadNewPage()
    }

    func select(series: Series) {
        self.feedService.series(with: series.code)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func openFilter() {
        self.feedService.fetchFiltedData()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] data in
                self?.router.open(filter: self!.filter, data: data)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func search() {
        self.router.openSearchScreen()
    }

    private func update(filter: SeriesFilter) {
        self.filter = filter
        self.view.setFilter(active: self.filter != SeriesFilter())
        self.refresh()
    }

    private func setupPaginator() {
        var pageActivity: ActivityDisposable?

        self.paginator.handler
            .showData { [weak self] value in
                switch value.data {
                case let .first(items):
                    self?.view.set(items: items)
                case let .next(items):
                    self?.view.append(items: items)
                }
                self?.activity?.dispose()
            }
            .showEmptyError { [weak self] value in
                if let error = value.error {
                    self?.router.show(error: error)
                }
                self?.activity?.dispose()
            }
            .showPageProgress { [weak self] show in
                if show {
                    pageActivity = self?.view.loadPageProgress()
                } else {
                    pageActivity?.dispose()
                }
            }
    }
}
