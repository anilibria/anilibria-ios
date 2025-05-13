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

    private let mainService: MainService
    private var menuService: MenuService

    private var bag = Set<AnyCancellable>()
    private var activity: ActivityDisposable?
    private var lastRefreshDate: Date?
    private let refreshInterval: TimeInterval = 3600

    private lazy var randomSeries = ActionItem(L10n.Screen.Feed.randomRelease) { [weak self] in
        self?.selectRandom()
    }

    private lazy var history = ActionItem(L10n.Screen.Feed.history) { [weak self] in
        self?.selectHistory()
    }

    private var soonViewModel: SoonViewModel?

    init(mainService: MainService,
         menuService: MenuService) {
        self.mainService = mainService
        self.menuService = menuService

        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refreshIfNeeded()
            }
            .store(in: &bag)
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

    func refreshIfNeeded() {
        if let date = lastRefreshDate {
            let duration = Date().timeIntervalSince1970 - date.timeIntervalSince1970
            if duration >= refreshInterval {
                refresh()
            }
        }
    }

    func select(news: News) {
        self.router.open(url: .web(news.vidUrl))
    }

    func select(series: Series) {
        self.router.open(series: series)
    }

    func selectRandom() {
        self.mainService.fetchRandom()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                if let item {
                    self?.router.open(series: item)
                }
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

    func open(promo: PromoItem) {
        switch promo.content {
        case .ad(let ad):
            router.open(url: .web(ad.url))
        case .promo(let item):
            router.open(url: .web(item.url))
        case .release(let series):
            select(series: series)
        case nil:
            break
        }
    }

    private func load() {
        Publishers.Zip(
            mainService.fetchPromo(),
            mainService.fetchTodaySchedule()
        ).sink(onNext: { [weak self] promo, schedule in
            self?.create(promo: promo, schedule: schedule)
            self?.activity = nil
            self?.lastRefreshDate = Date()
        }, onError: { [weak self] error in
            self?.router.show(error: error)
            self?.activity = nil
        })
        .store(in: &bag)
    }

    private func create(promo: [PromoItem], schedule: ShortSchedule) {
        var items: [any Hashable] = []

        let promoModel = PromoViewModel(items: promo) { [weak self] item in
            self?.open(promo: item)
        }

        items.append(promoModel)
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
