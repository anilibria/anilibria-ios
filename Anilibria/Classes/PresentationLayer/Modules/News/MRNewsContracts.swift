import UIKit

// MARK: - Contracts

protocol NewsViewBehavior: WaitingBehavior, InfinityLoadingBehavior {
    func set(items: [News])
    func append(items: [News])
}

protocol NewsEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func bind(view: NewsViewBehavior, router: NewsRoutable)

    func select(news: News)
}
