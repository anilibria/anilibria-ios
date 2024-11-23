import UIKit

// MARK: - Contracts

protocol CatalogViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(model: CatalogViewModel)
    func scrollToTop()
    func setFilter(active: Bool)
}

protocol CatalogEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: CatalogViewBehavior,
              router: CatalogRoutable,
              filter: SeriesFilter)

    func select(series: Series)
    func openFilter()
    func search()
}
