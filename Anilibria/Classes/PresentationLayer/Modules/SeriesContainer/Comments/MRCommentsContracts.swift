import UIKit

// MARK: - Contracts

protocol CommentsViewBehavior: WaitingBehavior {
    func set(html: String, baseUrl: URL?, cookie: HTTPCookie?)
}

protocol CommentsEventHandler: ViewControllerEventHandler {
    func bind(view: CommentsViewBehavior,
              router: CommentsRoutable,
              series: Series)
    func sendButtonTapped()
}
