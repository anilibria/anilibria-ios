import DITranquillity
import Combine
import UIKit

final class MainContainerPart: DIPart {
    static func load(container: DIContainer) {
        container.register(MainContainerPresenter.init)
            .as(MainContainerEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class MainContainerPresenter {
    private weak var view: MainContainerViewBehavior!
    private var router: MainContainerRoutable!

    private let menuService: MenuService
    private let sessionService: SessionService
    private let notifyService: NotifyService
    private let feedService: FeedService

    private var bag = Set<AnyCancellable>()

    init(menuService: MenuService,
         sessionService: SessionService,
         notifyService: NotifyService,
         feedService: FeedService) {
        self.menuService = menuService
        self.sessionService = sessionService
        self.notifyService = notifyService
        self.feedService = feedService
    }
}

extension MainContainerPresenter: MainContainerEventHandler {
    func bind(view: MainContainerViewBehavior, router: MainContainerRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.setupNotify()
        let items = self.menuService.fetchItems()
        self.view.set(items: items)

        self.select(item: .feed)

        self.menuService.fetchCurrentItem()
            .sink(onNext: { [weak self] type in
                self?.view.set(selected: type)
                self?.router.open(menu: type)
            })
            .store(in: &bag)

        self.sessionService
            .fetchState()
            .sink(onNext: { [weak self] value in
                switch value {
                case .guest:
                    if let current = self?.menuService.getSelected(), current == .favorite {
                        self?.menuService.setMenuItem(type: .feed)
                    }
                    self?.view.change(visible: false, for: .favorite)
                case .user:
                    self?.view.change(visible: true, for: .favorite)
                }

            })
            .store(in: &bag)
    }

    func select(item: MenuItemType) {
        self.menuService.setMenuItem(type: item)
    }

    private func setupNotify() {
        self.notifyService.registerForRemoteNotification()

        self.notifyService.fetchDataSequence()
            .sink(onNext: { [weak self] data in
                if let link = data.link {
                    self?.handle(url: link)
                }
            })
            .store(in: &bag)
    }

    private func handle(url: URL) {
        if let code = URLHelper.isRelease(url: url) {
            self.load(code: code)
        } else {
            self.router.open(url: .web(url))
        }
    }

    private func load(code: String) {
        self.feedService.series(with: code)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }
}
