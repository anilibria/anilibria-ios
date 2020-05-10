import UIKit

// MARK: - Router

protocol SeriesRoutable: BaseRoutable,
    BackRoute,
    PlayerRoute,
    AppUrlRoute,
    AlertRoute {}

final class SeriesRouter: BaseRouter, SeriesRoutable {}
