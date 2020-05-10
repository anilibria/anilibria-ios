import IGListKit
import UIKit

// MARK: - Contracts

protocol FavoriteViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [ListDiffable])
}

protocol FavoriteEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: FavoriteViewBehavior, router: FavoriteRoutable)

    func unfavorite(series: Series)
    func select(series: Series)
    func search(query: String)
}
