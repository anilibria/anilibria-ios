import DITranquillity
import Combine
import UIKit

final class HistoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(HistoryPresenter.init)
            .as(HistoryEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class HistoryPresenter {
    private weak var view: HistoryViewBehavior!
    private var router: HistoryRoutable!
    private var items: [Series] = []
    private var query: String = ""
    private var bag = Set<AnyCancellable>()

    let playerService: PlayerService
    let feedService: FeedService

    init(playerService: PlayerService,
         feedService: FeedService) {
        self.playerService = playerService
        self.feedService = feedService
    }
}

extension HistoryPresenter: HistoryEventHandler {
    func bind(view: HistoryViewBehavior, router: HistoryRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.playerService
            .fetchSeriesHistory()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] items in
                self?.items = items
                self?.showItems()
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func delete(series: Series) {
        self.items.removeAll(where: { $0.id == series.id })
        self.showItems()
        self.playerService.removeHistory(for: series)
            .sink()
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

    func search(query: String) {
        self.query = query.lowercased()
        self.showItems()
    }

    private func showItems() {
        DispatchQueue.global().async { [weak self] in
            guard var result = self?.items, let query = self?.query else {
                return
            }

            if query.isEmpty == false {
                result = result.filter {
                    ($0.name?.main ?? "").contains(where: { $0.lowercased().contains(query) })
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.view.set(items: result)
            }
        }
    }
}
