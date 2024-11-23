import UIKit

// MARK: - Router

protocol FavoriteRoutable: BaseRoutable, SeriesRoute, FilterRoute {}

final class FavoriteRouter: BaseRouter, FavoriteRoutable {}
