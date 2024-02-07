import UIKit

// MARK: - Router

protocol FeedRoutable: BaseRoutable,
    AppUrlRoute,
    ScheduleRoute,
    SearchRoute,
    SeriesRoute,
    HistoryRoute,
    LocalFilesRoute {}

final class FeedRouter: BaseRouter, FeedRoutable {}
