import DITranquillity
import Combine
import UIKit

final class FeedPart: DIPart {
    static func load(container: DIContainer) {
        container.register(FeedPresenter.init)
            .as(FeedEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class FeedPresenter {
    private weak var view: FeedViewBehavior!
    private var router: FeedRoutable!

    private let feedService: FeedService
    private var menuService: MenuService

    private var bag = Set<AnyCancellable>()
    private var activity: ActivityDisposable?
    private var schedules: [Schedule] = []
    private let updates = TitleItem(L10n.Screen.Feed.updatesTitle)
   
    private var nextPage: Int = 1
    private var pageSubscriber: AnyCancellable?

    private lazy var randomSeries = ActionItem(L10n.Screen.Feed.randomRelease) { [weak self] in
        self?.selectRandom()
    }

    private lazy var history = ActionItem(L10n.Screen.Feed.history) { [weak self] in
        self?.selectHistory()
    }

    private lazy var pagination = PaginationViewModel { [weak self] completion in
        self?.loadPage(completion: completion)
    }

    init(feedService: FeedService,
         menuService: MenuService) {
        self.feedService = feedService
        self.menuService = menuService
    }
}

extension FeedPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let searchCommand = command as? SearchResultCommand {
            switch searchCommand.value {
            case let .series(item):
                self.select(series: item)
            case let .google(query):
                self.router.open(url: .google(query))
            case .filter:
                self.menuService.setMenuItem(type: .catalog)
            }
            return true
        }
        return false
    }
}

extension FeedPresenter: FeedEventHandler {
    func bind(view: FeedViewBehavior, router: FeedRoutable) {
        self.view = view
        self.router = router
        self.router.responder = self
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

    func selectRandom() {
        self.feedService.fetchRandom()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func selectHistory() {
        self.router.openHistory()
    }

    func search() {
        self.router.openSearchScreen()
    }

    func allSchedule() {
        if !self.schedules.isEmpty {
            self.router.open(schedules: self.schedules)
        }
    }

    private func load() {
        nextPage = 1
        
        Publishers.Zip(
            self.feedService.fetchSchedule(),
            self.feedService.fetchFeed(page: nextPage)
        ).sink(onNext: { [weak self] schedules, feeds in
            self?.nextPage += 1
            self?.create(schedules: schedules, feeds: feeds)
            self?.activity = nil
        }, onError: { [weak self] error in
            self?.router.show(error: error)
            self?.activity = nil
        })
        .store(in: &bag)
    }
    
    private func loadPage(completion: @escaping Action<Bool>) {
        pageSubscriber = self.feedService.fetchFeed(page: nextPage)
            .sink(onNext: { [weak self] feeds in
                self?.nextPage += 1
                self?.append(feeds)
                completion(feeds.isEmpty)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
                completion(false)
            })
    }

    private func create(schedules: [Schedule], feeds: [Feed]) {
        self.schedules = schedules
        var scheduleBlock = [NSObject]()
        if !schedules.isEmpty {
            let scheduleAction = ActionItem(L10n.Screen.Feed.schedule) { [weak self] in
                self?.allSchedule()
            }

            let mskDay = WeekDay.getMsk()
            if let currentSchedule = schedules.first(where: { $0.day == mskDay }) {
                if currentSchedule.items.isEmpty == false {
                    scheduleBlock.append(currentSchedule)
                }
            }
            scheduleBlock.append(scheduleAction)
        }
       

        var items: [any Hashable] = []
        items.append(contentsOf: scheduleBlock)
        items.append(randomSeries)
        items.append(history)
        items.append(updates)
        items.append(contentsOf: feeds.compactMap { $0.value })
        items.append(pagination)
        self.view.set(items: items)
    }

    private func append(_ feeds: [Feed]) {
        let items: [any Hashable] = feeds.compactMap { $0.value }
        self.view.append(items: items + [pagination])
    }
}
