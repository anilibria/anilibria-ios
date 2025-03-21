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
    private var activity: ActivityDisposable?

    private let sessionService: SessionService
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
        self.view.set(providers: AuthProvider.allCases)
    }

    func back() {
        self.router.backToRoot()
    }

    func login(login: String, password: String) {
        bag.removeAll()
        self.sessionService
            .signIn(login: login, password: password)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] _ in
                self?.back()
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func cancel() {
        activity?.dispose()
    }

    func login(with provider: AuthProvider) {
        bag.removeAll()
        activity = view.showLoading(fullscreen: false)
        self.sessionService.getDataFor(provider: provider)
            .sink(onNext: { [weak self] data in
                self?.router.open(url: data.url)
                let item = DispatchWorkItem {
                    self?.tryLogin(with: data)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: item)
                self?.bag.insert(AnyCancellable { item.cancel() })

            }, onError: { [weak self] error in
                self?.activity?.dispose()
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func signUp() {
        router.open(url: .web(URLS.signUp))
    }

    func resetPassword() {
        router.showRestoreScreen()
    }

    private func tryLogin(with data: AuthProviderData) {
        self.sessionService.signIn(with: data)
            .sink(onNext: { [weak self] _ in
                self?.back()
            }, onError: { [weak self] error in
                self?.activity?.dispose()
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }
}
