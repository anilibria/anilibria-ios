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

    private let mainService: MainService

    private var bag = Set<AnyCancellable>()
    private var activity: ActivityDisposable?
    private var pageSubscriber: AnyCancellable?

    init(newsService: MainService) {
        self.mainService = newsService
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
        pageSubscriber = mainService.fetchNews(limit: 30)
            .sink(onNext: { [weak self] items in
                self?.set(items: items)
                self?.activity = nil
            }, onError: { [weak self] error in
                self?.router.show(error: error)
                self?.activity = nil
            })
    }
    
    private func set(items: [News]) {
        self.view.set(items: items)
    }
}
