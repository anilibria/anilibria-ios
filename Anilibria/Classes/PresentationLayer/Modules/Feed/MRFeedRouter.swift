import UIKit

// MARK: - Router

protocol FeedRoutable: BaseRoutable,
    AppUrlRoute,
    ScheduleRoute,
    SearchRoute,
    SeriesRoute {}

final class FeedRouter: BaseRouter, FeedRoutable {}
