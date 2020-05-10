import DITranquillity
import RxSwift
import UIKit

final class SocialAuthPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SocialAuthPresenter.init)
            .as(SocialAuthEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SocialAuthPresenter {
    private weak var view: SocialAuthViewBehavior!
    private var router: SocialAuthRoutable!
    private var socialData: SocialOAuthData!

    private let sessionService: SessionService

    private let bag: DisposeBag = DisposeBag()

    init(sessionService: SessionService) {
        self.sessionService = sessionService
    }
}

extension SocialAuthPresenter: SocialAuthEventHandler {
    func bind(view: SocialAuthViewBehavior,
              router: SocialAuthRoutable,
              socialData: SocialOAuthData) {
        self.view = view
        self.router = router
        self.socialData = socialData
    }

    func didLoad() {
        if let url = self.socialData.socialUrl {
            self.view.set(url: url)
        }
    }

    func back() {
        self.router.back()
    }

    func redirect(url: URL) -> Bool {
        let authUrl = url.absoluteString ~= self.socialData.resultPattern

        if authUrl {
            self.auth(with: url)
        }

        return authUrl
    }

    private func auth(with url: URL) {
        self.sessionService
            .signInSocial(url: url)
            .manageActivity(self.view.showLoading(fullscreen: true))
            .subscribe(onSuccess: { [weak self] _ in
                self?.router.dissmiss()
            }, onError: { [weak self] error in
                self?.back()
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
    }
}
