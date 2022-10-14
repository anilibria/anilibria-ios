import Foundation

protocol RefreshEventHandler: AnyObject {
    func refresh()
}

protocol RefreshBehavior {
    func showRefreshIndicator() -> ActivityDisposable?
}

protocol InfinityLoadingEventHandler: RefreshEventHandler {
    func loadMore()
}

protocol InfinityLoadingBehavior: RefreshBehavior {
    func loadPageProgress() -> ActivityDisposable?
}

extension InfinityLoadingEventHandler {
    func refresh() {}
    func loadMore() {}
}
