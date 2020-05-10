import IGListKit
import UIKit

// MARK: - Contracts

protocol ScheduleViewBehavior: WaitingBehavior {
    func set(items: [ListDiffable])
}

protocol ScheduleEventHandler: ViewControllerEventHandler {
    func bind(view: ScheduleViewBehavior,
              router: ScheduleRoutable,
              schedules: [Schedule])

    func select(series: Series)
}
