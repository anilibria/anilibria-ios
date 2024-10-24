import UIKit

// MARK: - Contracts

protocol CatalogViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [any Hashable])
    func append(items: [any Hashable])
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
