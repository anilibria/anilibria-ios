import UIKit

// MARK: - Router

protocol OtherRoutable: BaseRoutable,
    AppUrlRoute,
    SafariRoute,
    SignInRoute,
    SettingsRoute,
    HistoryRoute {}

final class OtherRouter: BaseRouter, OtherRoutable {}
