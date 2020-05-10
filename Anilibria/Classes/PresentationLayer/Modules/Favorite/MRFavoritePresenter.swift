import DITranquillity
import RxSwift
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
    private var items: [Series] = []
    private var query: String = ""
    private var bag: DisposeBag = DisposeBag()

    let favoriteService: FavoriteService
    let feedService: FeedService

    init(favoriteService: FavoriteService,
         feedService: FeedService) {
        self.favoriteService = favoriteService
        self.feedService = feedService
    }
}

extension FavoritePresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let command = command as? FavoriteCommand {
            if command.added {
                self.append(series: command.value)
            } else {
                self.remove(series: command.value)
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
    }

    func didLoad() {
        self.load(with: self.view.showLoading(fullscreen: false))
    }

    func refresh() {
        self.load(with: self.view.showRefreshIndicator())
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
                    $0.names.contains(where: { $0.lowercased().contains(query) })
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.view.set(items: result)
            }
        }
    }

    func unfavorite(series: Series) {
        self.favoriteService
            .favorite(add: false, series: series)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .subscribe(onSuccess: { [weak self] _ in
                self?.remove(series: series)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
    }

    func select(series: Series) {
        self.feedService.series(with: series.code)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .subscribe(onSuccess: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
    }

    private func load(with activity: ActivityDisposable?) {
        self.favoriteService
            .fetchSeries()
            .manageActivity(activity)
            .subscribe(onSuccess: { [weak self] items in
                self?.items = items
                self?.showItems()
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
    }

    private func remove(series: Series) {
        self.items.removeAll(where: { $0.id == series.id })
        self.showItems()
    }

    private func append(series: Series) {
        self.items.insert(series, at: 0)
        self.showItems()
    }
}

struct FavoriteCommand: RouteCommand {
    let added: Bool
    let value: Series
}
