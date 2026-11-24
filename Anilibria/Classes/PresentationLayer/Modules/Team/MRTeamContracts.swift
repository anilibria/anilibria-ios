import UIKit

// MARK: - Contracts

protocol TeamViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(items: [TeamGroup])
    func scrollToTop()
}

protocol TeamEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: TeamViewBehavior,
              router: TeamRoutable)
}
