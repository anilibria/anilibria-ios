import UIKit

// MARK: - Contracts

protocol OtherViewBehavior: WaitingBehavior {
    func set(user: User?, loading: Bool)
    func set(links: [LinkData])
}

protocol OtherEventHandler: ViewControllerEventHandler {
    func bind(view: OtherViewBehavior, router: OtherRoutable)

    func team()
    func donate()

    func settings()
    func history()
    func linkDevice()

    func loginOrLogout()

    func tap(link: LinkData)
}
