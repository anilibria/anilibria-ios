import UIKit

// MARK: - Router

protocol SeriesRoutable: BaseRoutable,
                         BackRoute,
                         PlayerRoute,
                         AppUrlRoute,
                         AlertRoute,
                         ShareRoute,
                         CatalogRoute,
                         SignInRoute,
                         ActionSheetRoute,
                         SeriesRoute {}

final class SeriesRouter: BaseRouter, SeriesRoutable {}
