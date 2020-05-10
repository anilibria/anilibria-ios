import UIKit

// MARK: - Router

protocol SeriesContainerRoutable: BaseRoutable,
    CatalogRoute,
    SeriesRoute,
    ScheduleRoute,
    SafariRoute,
    ShareRoute {}

final class SeriesContainerRouter: BaseRouter, SeriesContainerRoutable {}
