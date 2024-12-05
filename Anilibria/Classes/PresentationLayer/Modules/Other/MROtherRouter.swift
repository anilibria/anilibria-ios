import UIKit

// MARK: - Router

protocol OtherRoutable: BaseRoutable,
    AppUrlRoute,
    SafariRoute,
    SignInRoute,
    SettingsRoute,
    HistoryRoute,
    LinkDeviceRoute,
    TeamRoute {}

final class OtherRouter: BaseRouter, OtherRoutable {}
