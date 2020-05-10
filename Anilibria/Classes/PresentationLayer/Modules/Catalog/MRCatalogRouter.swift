import UIKit

// MARK: - Router

protocol CatalogRoutable: BaseRoutable, FilterRoute, SearchRoute, SeriesRoute, AppUrlRoute {}

final class CatalogRouter: BaseRouter, CatalogRoutable {}
