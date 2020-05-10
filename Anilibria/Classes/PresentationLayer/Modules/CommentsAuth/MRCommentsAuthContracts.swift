import UIKit

// MARK: - Contracts

protocol CommentsAuthViewBehavior: WaitingBehavior {}

protocol CommentsAuthEventHandler: ViewControllerEventHandler {
    func bind(view: CommentsAuthViewBehavior, router: CommentsAuthRoutable)
    func back()
    func pageStartLoading()
    func pageFinishLoading()
    func success()
}
