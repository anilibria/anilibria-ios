import DITranquillity
import Foundation
import Combine

final class MenuServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(MenuServiceImp.init)
            .as(MenuService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol MenuService {
    func fetchCurrentItem() -> AnyPublisher<MenuItemType, Never>
    func getSelected() -> MenuItemType?
    func setMenuItem(type: MenuItemType)
    func fetchItems() -> [MenuItem]
}

final class MenuServiceImp: MenuService {
    private let currentItem: CurrentValueSubject<MenuItemType?, Never> = CurrentValueSubject(nil)

    func getSelected() -> MenuItemType? {
        return self.currentItem.value
    }

    func fetchCurrentItem() -> AnyPublisher<MenuItemType, Never> {
        return self.currentItem
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func setMenuItem(type: MenuItemType) {
        self.setMenuItem(type: type, animated: true)
    }

    func setMenuItem(type: MenuItemType, animated: Bool) {
        self.currentItem.send(type)
    }

    func fetchItems() -> [MenuItem] {
        return MenuItemsFactory.create()
    }
}
