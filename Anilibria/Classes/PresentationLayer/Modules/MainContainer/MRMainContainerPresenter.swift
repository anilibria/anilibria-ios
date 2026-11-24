import DITranquillity
import Combine

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
    private let menuService: MenuService
    private let sessionService: SessionService

    private var bag = Set<AnyCancellable>()

    init(menuService: MenuService,
         sessionService: SessionService) {
        self.menuService = menuService
        self.sessionService = sessionService
    }
}

extension MainContainerPresenter: MainContainerEventHandler {
    func bind(view: MainContainerViewBehavior) {
        self.view = view
    }

    func didLoad() {
        let items = self.menuService.fetchItems()
        self.view.set(items: items)

        self.select(item: .feed)

        self.menuService.fetchCurrentItem()
            .sink(onNext: { [weak self] type in
                self?.view.set(selected: type)
            })
            .store(in: &bag)

        self.sessionService
            .fetchState()
            .sink(onNext: { [weak self] value in
                switch value {
                case .guest:
                    if let current = self?.menuService.getSelected(), current == .collections {
                        self?.menuService.setMenuItem(type: .feed)
                    }
                    self?.view.change(visible: false, for: .collections)
                case .user:
                    self?.view.change(visible: true, for: .collections)
                }

            })
            .store(in: &bag)
    }

    func select(item: MenuItemType) {
        self.menuService.setMenuItem(type: item)
    }
}
