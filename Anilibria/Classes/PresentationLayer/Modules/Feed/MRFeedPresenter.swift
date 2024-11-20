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

    private lazy var randomSeries = ActionItem(L10n.Screen.Feed.randomRelease) { [weak self] in
        self?.selectRandom()
    }

    private lazy var history = ActionItem(L10n.Screen.Feed.history) { [weak self] in
        self?.selectHistory()
    }

    private var soonViewModel: SoonViewModel?

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
        router.openWeekSchedule()
    }

    private func load() {
        self.feedService.fetchTodaySchedule().sink(onNext: { [weak self] schedule in
            self?.create(schedule: schedule)
            self?.activity = nil
        }, onError: { [weak self] error in
            self?.router.show(error: error)
            self?.activity = nil
        })
        .store(in: &bag)
    }

    private func create(schedule: ShortSchedule) {
        var items: [any Hashable] = []
        items.append([randomSeries, history])

        if schedule.items.isEmpty == false {
            soonViewModel = SoonViewModel(schedule)
            soonViewModel?.selectSeries = { [weak self] series in
                self?.select(series: series)
            }
            soonViewModel?.seeAllAction = { [weak self] in
                self?.allSchedule()
            }
            items.append(soonViewModel)
        }

        view.set(items: items)
    }
}
