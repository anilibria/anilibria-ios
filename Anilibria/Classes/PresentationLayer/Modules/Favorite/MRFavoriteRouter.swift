import UIKit

// MARK: - Router

protocol FavoriteRoutable: BaseRoutable, SeriesRoute {}

final class FavoriteRouter: BaseRouter, FavoriteRoutable {}
