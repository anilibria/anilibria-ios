import DITranquillity
import Foundation
import RxCocoa
import RxSwift

final class MenuServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(MenuServiceImp.init)
            .as(MenuService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol MenuService {
    func fetchCurrentItem() -> Observable<MenuItemType>
    func getSelected() -> MenuItemType?
    func setMenuItem(type: MenuItemType)
    func fetchItems() -> [MenuItem]
}

final class MenuServiceImp: MenuService {
    private let currentItem: BehaviorRelay<MenuItemType?> = BehaviorRelay(value: nil)
    private let schedulers: SchedulerProvider

    init(schedulers: SchedulerProvider) {
        self.schedulers = schedulers
    }

    func getSelected() -> MenuItemType? {
        return self.currentItem.value
    }

    func fetchCurrentItem() -> Observable<MenuItemType> {
        return self.currentItem.asObservable()
            .compactMap { $0 }
            .distinctUntilChanged()
    }

    func setMenuItem(type: MenuItemType) {
        self.setMenuItem(type: type, animated: true)
    }

    func setMenuItem(type: MenuItemType, animated: Bool) {
        self.currentItem.accept(type)
    }

    func fetchItems() -> [MenuItem] {
        return MenuItemsFactory.create()
    }
}
