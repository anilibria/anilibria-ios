import IGListKit
import UIKit

// MARK: - Contracts

protocol FilterViewBehavior: class {
    func set(items: [ListDiffable])
}

protocol FilterEventHandler: ViewControllerEventHandler {
    func bind(view: FilterViewBehavior,
              router: FilterRoutable,
              filter: SeriesFilter,
              data: FilterData)

    func change(filter: SeriesFilter)
    func apply()
    func reset()
    func back()
}
