import UIKit

// MARK: - Contracts

protocol NewsViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [NSObject])
    func append(items: [NSObject])
}

protocol NewsEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: NewsViewBehavior, router: NewsRoutable)

    func select(news: News)
}
