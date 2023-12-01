import Foundation

protocol RefreshEventHandler: AnyObject {
    func refresh()
}

protocol RefreshBehavior {
    func showRefreshIndicator() -> ActivityDisposable?
}
