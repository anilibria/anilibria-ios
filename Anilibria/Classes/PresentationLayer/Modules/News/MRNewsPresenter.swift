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
    private var pageSubscriber: AnyCancellable?
    private var nextPage: Int = 0
    
    private lazy var pagination = PaginationViewModel { [weak self] completion in
        self?.loadPage(completion: completion)
    }

    init(newsService: FeedService) {
        self.feedService = newsService
    }
}

extension NewsPresenter: NewsEventHandler {
    func bind(view: NewsViewBehavior, router: NewsRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.activity = self.view.showLoading(fullscreen: false)
        self.load()
    }

    func refresh() {
        self.activity = self.view.showRefreshIndicator()
        self.load()
    }

    func select(news: News) {
        self.router.open(url: .web(news.vidUrl))
    }
    
    private func load() {
        nextPage = 0
        pageSubscriber = feedService.fetchNews(page: nextPage)
            .sink(onNext: { [weak self] items in
                self?.nextPage += 1
                self?.set(items: items)
                self?.activity = nil
            }, onError: { [weak self] error in
                self?.router.show(error: error)
                self?.activity = nil
            })
    }
    
    private func loadPage(completion: @escaping Action<Bool>) {
        pageSubscriber = feedService.fetchNews(page: nextPage)
            .sink(onNext: { [weak self] items in
                self?.nextPage += 1
                self?.append(items: items)
                completion(items.isEmpty)
                self?.activity = nil
            }, onError: { [weak self] error in
                self?.router.show(error: error)
                completion(false)
                self?.activity = nil
            })
    }
    
    private func set(items: [News]) {
        self.view.set(items: items + [pagination])
    }
    
    private func append(items: [News]) {
        self.view.append(items: items + [pagination])
    }
}
