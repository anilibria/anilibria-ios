import IGListKit
import UIKit

// MARK: - Contracts

protocol CatalogViewBehavior: WaitingBehavior, InfinityLoadingBehavior {
    func set(items: [ListDiffable])
    func setFilter(active: Bool)
}

protocol CatalogEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func bind(view: CatalogViewBehavior,
              router: CatalogRoutable,
              filter: SeriesFilter)

    func select(series: Series)
    func openFilter()
    func search()
}
