import UIKit

// MARK: - Contracts

protocol FavoriteViewBehavior: WaitingBehavior, RefreshBehavior {
    func scrollToTop()
    func set(model: FavoriteViewModel)
    func setFilter(active: Bool)
    func seriesSelected()
}

protocol FavoriteEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: FavoriteViewBehavior, router: FavoriteRoutable)
    func search(query: String)
    func openFilter()
}
