import UIKit

// MARK: - Router

protocol SeriesRoutable: BaseRoutable,
    BackRoute,
    PlayerRoute,
    AppUrlRoute,
    AlertRoute,
    ShareRoute {}

final class SeriesRouter: BaseRouter, SeriesRoutable {}
