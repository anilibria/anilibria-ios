import UIKit

// MARK: - Contracts

protocol CatalogViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [NSObject])
    func append(items: [NSObject])
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
