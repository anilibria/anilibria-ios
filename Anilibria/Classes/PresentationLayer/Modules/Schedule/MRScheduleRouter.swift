import UIKit

// MARK: - Router

protocol ScheduleRoutable: BaseRoutable, SeriesRoute {}

final class ScheduleRouter: BaseRouter, ScheduleRoutable {}
