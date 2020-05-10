import UIKit

// MARK: - Router

protocol HistoryRoutable: BaseRoutable, SeriesRoute {}

final class HistoryRouter: BaseRouter, HistoryRoutable {}
