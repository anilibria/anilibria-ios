import UIKit

// MARK: - Router

protocol OtherRoutable: BaseRoutable,
    AppUrlRoute,
    SafariRoute,
    SignInRoute,
    SettingsRoute,
    HistoryRoute,
    TeamRoute {}

final class OtherRouter: BaseRouter, OtherRoutable {}
