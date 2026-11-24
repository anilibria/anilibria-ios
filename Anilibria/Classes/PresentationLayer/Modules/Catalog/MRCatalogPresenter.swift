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

    private let catalogService: CatalogService
    private var bag = Set<AnyCancellable>()

    let viewModel: CatalogViewModel

    init(catalogService: CatalogService) {
        self.catalogService = catalogService
        self.viewModel = CatalogViewModel(catalogService: catalogService)
        viewModel.select = { [weak self] item in
            self?.select(series: item)
        }
    }
}

extension CatalogPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let filterCommand = command as? FilterRouteCommand {
            if viewModel.searchData.filter != filterCommand.value {
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
              data: SeriesSearchData) {
        self.view = view
        self.router = router
        self.router.responder = self
        viewModel.router = router
        viewModel.searchData = data
    }

    func didLoad() {
        self.view.set(model: viewModel)
        self.view.setFilter(active: !viewModel.searchData.filter.isEmpty)
        viewModel.load(activity: view.showLoading(fullscreen: false))
    }

    func refresh() {
        viewModel.load(activity: self.view.showRefreshIndicator())
    }

    func select(series: Series) {
        router.open(series: series)
    }

    func openFilter() {
        self.catalogService.fetchFilterData()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] data in
                guard let self else { return }
                router.open(filter: viewModel.searchData.filter, data: data)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func search() {
        self.router.openSearchScreen()
    }

    private func update(filter: SeriesSearchData.Filter) {
        view.scrollToTop()
        viewModel.searchData.filter = filter
        view.setFilter(active: !viewModel.searchData.filter.isEmpty)
        refresh()
    }
}
