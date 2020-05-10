import IGListKit
import UIKit

// MARK: - Contracts

protocol FeedViewBehavior: WaitingBehavior, InfinityLoadingBehavior {
    func set(items: [ListDiffable])
}

protocol FeedEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func bind(view: FeedViewBehavior, router: FeedRoutable)

    func select(news: News)
    func select(series: Series)
    func allSchedule()
    func search()
}
