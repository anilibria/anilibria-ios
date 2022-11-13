import UIKit

// MARK: - Router

protocol SeriesRoutable: BaseRoutable,
    BackRoute,
    PlayerRoute,
    AppUrlRoute,
    TorrentListRoute,
    AlertRoute {}

final class SeriesRouter: BaseRouter, SeriesRoutable {}
