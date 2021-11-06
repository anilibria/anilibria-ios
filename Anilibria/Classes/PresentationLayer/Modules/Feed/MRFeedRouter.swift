import UIKit

// MARK: - Router

protocol FeedRoutable: BaseRoutable,
    AppUrlRoute,
    ScheduleRoute,
    SearchRoute,
    SeriesRoute,
    HistoryRoute {}

final class FeedRouter: BaseRouter, FeedRoutable {}
