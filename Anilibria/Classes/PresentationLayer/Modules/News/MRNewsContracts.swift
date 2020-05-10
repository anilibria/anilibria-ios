import IGListKit
import UIKit

// MARK: - Contracts

protocol NewsViewBehavior: WaitingBehavior, InfinityLoadingBehavior {
    func set(items: [ListDiffable])
}

protocol NewsEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func bind(view: NewsViewBehavior, router: NewsRoutable)

    func select(news: News)
}
