import UIKit

// MARK: - Contracts

protocol FilterViewBehavior: AnyObject {
    func set(sorting: FilterSingleItem?, years: FilterRangeItem?, items: [FilterTagsItem])
}

protocol FilterEventHandler: ViewControllerEventHandler {
    func bind(view: FilterViewBehavior,
              router: FilterRoutable,
              filter: SeriesSearchData.Filter,
              data: FilterData)

    func apply()
    func reset()
    func back()
}
