import UIKit

// MARK: - Contracts

protocol MainContainerViewBehavior: WaitingBehavior {
    func set(items: [MenuItem])
    func set(selected: MenuItemType)
    func change(visible: Bool, for item: MenuItemType)
}

protocol MainContainerEventHandler: ViewControllerEventHandler {
    func bind(view: MainContainerViewBehavior, router: MainContainerRoutable)

    func select(item: MenuItemType)
}
