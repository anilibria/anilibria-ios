import UIKit

// MARK: - Contracts

protocol HistoryViewBehavior: WaitingBehavior {
    func set(items: [Series])
}

protocol HistoryEventHandler: ViewControllerEventHandler {
    func bind(view: HistoryViewBehavior, router: HistoryRoutable)

    func delete(series: Series)
    func select(series: Series)
    func search(query: String)
}
