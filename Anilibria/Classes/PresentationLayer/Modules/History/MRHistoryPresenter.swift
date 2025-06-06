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
    let mainService: MainService

    init(playerService: PlayerService,
         mainService: MainService) {
        self.playerService = playerService
        self.mainService = mainService
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
        router.open(series: series)
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
