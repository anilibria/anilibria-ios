import UIKit

// MARK: - Router

protocol SeriesRoutable: BaseRoutable,
                         BackRoute,
                         PlayerRoute,
                         AppUrlRoute,
                         AlertRoute,
                         ShareRoute,
                         CatalogRoute {}

final class SeriesRouter: BaseRouter, SeriesRoutable {}
