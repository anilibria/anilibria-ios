import DITranquillity
import Combine
import UIKit

final class NewsPart: DIPart {
    static func load(container: DIContainer) {
        container.register(NewsPresenter.init)
            .as(NewsEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class NewsPresenter {
    private weak var view: NewsViewBehavior!
    private var router: NewsRoutable!

    private let feedService: FeedService

    private var bag = Set<AnyCancellable>()
    private var activity: ActivityDisposable?

    private lazy var paginator: Paginator = Paginator<News, IntPaging>(IntPaging()) { [unowned self] in
        return self.feedService.fetchNews(page: $0)
    }

    init(newsService: FeedService) {
        self.feedService = newsService
    }

    deinit {
        self.paginator.release()
    }
}

extension NewsPresenter: NewsEventHandler {
    func bind(view: NewsViewBehavior, router: NewsRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
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

    func select(news: News) {
        self.router.open(url: .web(news.vidUrl))
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
