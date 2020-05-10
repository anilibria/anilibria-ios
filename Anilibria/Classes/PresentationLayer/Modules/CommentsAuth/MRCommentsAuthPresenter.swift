import DITranquillity
import RxSwift
import UIKit

final class CommentsAuthPart: DIPart {
    static func load(container: DIContainer) {
        container.register(CommentsAuthPresenter.init)
            .as(CommentsAuthEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class CommentsAuthPresenter {
    private weak var view: CommentsAuthViewBehavior!
    private var router: CommentsAuthRoutable!

    private let bag: DisposeBag = DisposeBag()
    private var activity: ActivityDisposable?
}

extension CommentsAuthPresenter: CommentsAuthEventHandler {
    func bind(view: CommentsAuthViewBehavior, router: CommentsAuthRoutable) {
        self.view = view
        self.router = router
    }

    func back() {
        self.router.back()
    }

    func pageStartLoading() {
        self.activity = self.view.showLoading(fullscreen: false)
    }

    func pageFinishLoading() {
        self.activity?.dispose()
    }

    func success() {
        self.activity = self.view.showLoading(fullscreen: true)
        let sequence = Single<HTTPCookie>.create { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == VKCookie.name }) {
                    observer(.success(cookie))
                    return
                }
                observer(.error(AppError.error(code: -1)))
            }
            return Disposables.create()
        }

        sequence.retry(20)
            .subscribe(onSuccess: { [weak self] cookie in
                self?.router.execute(CommentsAuthSuccess(vkCookie: cookie))
                self?.activity?.dispose()
                self?.back()
            }, onError: { [weak self] _ in
                self?.activity?.dispose()
            })
            .disposed(by: self.bag)
    }
}

public struct CommentsAuthSuccess: RouteCommand {
    let vkCookie: HTTPCookie
}
