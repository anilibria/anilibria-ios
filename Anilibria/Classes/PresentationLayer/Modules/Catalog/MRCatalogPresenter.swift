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
    private var pageSubscriber: AnyCancellable?
    private var filter: SeriesFilter = SeriesFilter()
    private var nextPage: Int = 0
    
    private lazy var pagination = PaginationViewModel { [weak self] completion in
        self?.loadPage(completion: completion)
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
        self.activity = self.view.showLoading(fullscreen: false)
        self.load()
    }

    func refresh() {
        self.activity = self.view.showRefreshIndicator()
        self.load()
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
    
    private func load() {
        nextPage = 0
        pageSubscriber = feedService.fetchCatalog(page: nextPage, filter: filter)
            .sink(onNext: { [weak self] feeds in
                self?.nextPage += 1
                self?.set(items: feeds)
                self?.activity = nil
            }, onError: { [weak self] error in
                self?.router.show(error: error)
                self?.activity = nil
            })
    }
    
    private func loadPage(completion: @escaping Action<Bool>) {
        pageSubscriber = feedService.fetchCatalog(page: nextPage, filter: filter)
            .sink(onNext: { [weak self] feeds in
                self?.nextPage += 1
                self?.append(items: feeds)
                completion(feeds.isEmpty)
                self?.activity = nil
            }, onError: { [weak self] error in
                self?.router.show(error: error)
                completion(false)
                self?.activity = nil
            })
    }
    
    private func set(items: [Series]) {
        self.view.set(items: items + [pagination])
    }
    
    private func append(items: [Series]) {
        self.view.append(items: items + [pagination])
    }

    private func update(filter: SeriesFilter) {
        self.filter = filter
        self.view.setFilter(active: self.filter != SeriesFilter())
        self.refresh()
    }
}
