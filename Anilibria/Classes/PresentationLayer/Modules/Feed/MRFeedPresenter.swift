import DITranquillity
import RxSwift
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

    private var bag: DisposeBag! = DisposeBag()
    private var activity: ActivityDisposable?
    private var items: [NSObject] = []
    private var scheduleBlock: [NSObject] = []
    private var schedules: [Schedule] = []
    private let updates = TitleItem(L10n.Screen.Feed.updatesTitle)

    private lazy var randomSeries = ActionItem(L10n.Screen.Feed.randomRelease) { [weak self] in
        self?.selectRandom()
    }

    private lazy var history = ActionItem(L10n.Screen.Feed.history) { [weak self] in
        self?.selectHistory()
    }

    private lazy var paginator: Paginator = Paginator<Feed, IntPaging>(IntPaging()) { [unowned self] in
        return self.feedService.fetchFeed(page: $0)
    }

    init(feedService: FeedService,
         menuService: MenuService) {
        self.feedService = feedService
        self.menuService = menuService
    }

    deinit {
        self.paginator.release()
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
        self.setupPaginator()
        self.activity = self.view.showLoading(fullscreen: false)
        self.load()
    }

    func refresh() {
        self.activity = self.view.showRefreshIndicator()
        self.load()
    }

    func loadMore() {
        self.paginator.loadNewPage()
    }

    func select(news: News) {
        self.router.open(url: .web(news.vidUrl))
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

    func selectRandom() {
        self.feedService.fetchRandom()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .subscribe(onSuccess: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
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
        self.feedService.fetchSchedule()
            .afterDone { [weak self] in
                self?.paginator.refresh()
            }
            .subscribe(onSuccess: { [weak self] schedules in
                self?.createScheduleBlock(schedules)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })

            .disposed(by: self.bag)
    }

    private func createScheduleBlock(_ items: [Schedule]) {
        self.schedules = items
        self.scheduleBlock = []
        if items.isEmpty {
            return
        }
        let scheduleAction = ActionItem(L10n.Screen.Feed.schedule.uppercased()) { [weak self] in
            self?.allSchedule()
        }

        let mskDay = WeekDay.getMsk()
        if let currentSchedule = items.first(where: { $0.day == mskDay }) {
            if currentSchedule.items.isEmpty == false {
                self.scheduleBlock.append(currentSchedule)
            }
        }
        self.scheduleBlock.append(scheduleAction)
    }

    private func create(_ feeds: [Feed]) {
        self.items = self.scheduleBlock +
            [self.randomSeries, self.history, self.updates] +
            feeds.compactMap { $0.value }
    }

    private func append(_ feeds: [Feed]) {
        self.items.append(contentsOf: feeds.compactMap { $0.value })
    }

    private func update() {
        self.view.set(items: self.items)
    }

    private func setupPaginator() {
        var pageActivity: ActivityDisposable?

        self.paginator.handler
            .showData { [weak self] value in
                switch value.data {
                case let .first(items):
                    self?.create(items)
                case let .next(items):
                    self?.append(items)
                }
                self?.activity?.dispose()
                self?.update()
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
