import UIKit

// MARK: - Contracts

protocol FeedViewBehavior: WaitingBehavior, InfinityLoadingBehavior {
    func set(items: [NSObject])
    func append(items: [NSObject])
}

protocol FeedEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func bind(view: FeedViewBehavior, router: FeedRoutable)

    func select(news: News)
    func select(series: Series)
    func allSchedule()
    func search()
}
