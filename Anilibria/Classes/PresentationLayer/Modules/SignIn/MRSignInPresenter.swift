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
        self.router.back()
    }

    func register() {
//        self.router.open(url: .web(URLS.register))
    }

    func login(login: String, password: String) {
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

    func login(with provider: AuthProvider) {
        let activity = view.showLoading(fullscreen: false)
        self.sessionService.getDataFor(provider: provider)
            .sink(onNext: { [weak self] data in
                self?.router.open(url: data.url)
                let item = DispatchWorkItem {
                    self?.tryLogin(with: data, activity: activity)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: item)
                self?.bag.insert(AnyCancellable { item.cancel() })

            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    private func tryLogin(with data: AuthProviderData, activity: ActivityDisposable?) {
        self.sessionService.signIn(with: data)
            .sink(onNext: { [weak self] _ in
                activity?.dispose()
                self?.back()
            }, onError: { [weak self] error in
                activity?.dispose()
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }
}
