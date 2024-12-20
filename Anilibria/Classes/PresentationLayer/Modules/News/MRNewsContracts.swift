import UIKit

// MARK: - Contracts

protocol NewsViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [any Hashable])
}

protocol NewsEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: NewsViewBehavior, router: NewsRoutable)

    func select(news: News)
}
