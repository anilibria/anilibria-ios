import DITranquillity
import Combine
import UIKit

final class SignInPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SignInPresenter.init)
            .as(SignInEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SignInPresenter {
    private weak var view: SignInViewBehavior!
    private var router: SignInRoutable!

    private let sessionService: SessionService

    private var socialData: SocialOAuthData?
    private var bag = Set<AnyCancellable>()

    init(sessionService: SessionService) {
        self.sessionService = sessionService
    }
}

extension SignInPresenter: SignInEventHandler {
    func bind(view: SignInViewBehavior, router: SignInRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.sessionService
            .fetchSocialData()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] data in
                self?.socialData = data
                self?.view.set(socialLogin: true)
            }, onError: { [weak self] _ in
                self?.view.set(socialLogin: false)
            })
            .store(in: &bag)
    }

    func back() {
        self.router.back()
    }

    func register() {
        self.router.open(url: .web(URLS.register))
    }

    func socialLogin() {
        if let data = self.socialData {
            self.router.socialAuth(with: data)
        }
    }

    func login(login: String, password: String, code: String) {
        self.sessionService
            .signIn(login: login, password: password, code: code)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] _ in
                self?.back()
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }
}
