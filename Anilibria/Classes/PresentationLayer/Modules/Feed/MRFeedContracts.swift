import UIKit

// MARK: - Contracts

protocol FeedViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [NSObject])
    func append(items: [NSObject])
}

protocol FeedEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: FeedViewBehavior, router: FeedRoutable)

    func select(news: News)
    func select(series: Series)
    func allSchedule()
    func search()
}
