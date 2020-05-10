import DITranquillity
import UIKit

final class CommentsPart: DIPart {
    static func load(container: DIContainer) {
        container.register(CommentsPresenter.init)
            .as(CommentsEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class CommentsPresenter {
    private weak var view: CommentsViewBehavior!
    private var router: CommentsRoutable!
    private var series: Series!
}

extension CommentsPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let value = command as? CommentsAuthSuccess {
            self.load(with: value.vkCookie)
            return true
        }
        return false
    }
}

extension CommentsPresenter: CommentsEventHandler {
    func bind(view: CommentsViewBehavior,
              router: CommentsRoutable,
              series: Series) {
        self.view = view
        self.router = router
        self.series = series
        self.router.responder = self
    }

    func didLoad() {
        self.load(with: nil)
    }

    private func load(with cookie: HTTPCookie?) {
        if let comments = self.series.comments {
            let html = """
            <html>
                <head>
                    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
                </head>
                <body>
                    \(comments.script)
                </body>
            </html>
            """

            self.view.set(html: html,
                          baseUrl: comments.baseUrl,
                          cookie: cookie)
        }
    }

    func sendButtonTapped() {
        let cookies = self.vkCookies()
        if cookies.contains(where: { $0.name == VKCookie.name }) == true {
            return
        }

        self.router.commentsAuth()
    }

    private func vkCookies() -> [HTTPCookie] {
        return HTTPCookieStorage.shared.cookies(for: URL(string: "https://vk.com")!) ?? []
    }
}
