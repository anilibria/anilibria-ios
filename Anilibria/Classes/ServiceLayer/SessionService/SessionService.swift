import DITranquillity
import RxSwift

final class SessionServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(SessionServiceImp.init)
            .as(SessionService.self)
            .lifetime(.single)
    }
}

protocol SessionService: class {
    func fetchState() -> Observable<SessionState>

    func signIn(login: String, password: String, code: String) -> Single<User>
    func signInSocial(url: URL) -> Single<User>

    func fetchUser() -> Single<User>

    func fetchSocialData() -> Single<SocialOAuthData?>

    func forceLogout()
    func logout()
}

final class SessionServiceImp: SessionService {
    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository
    let userRepository: UserRepository
    let clearManager: ClearableManager

    private var bag: DisposeBag = DisposeBag()
    private var data: SocialOAuthData?

    private let statusRelay: BehaviorSubject<SessionState>

    init(schedulers: SchedulerProvider,
         clearManager: ClearableManager,
         backendRepository: BackendRepository,
         userRepository: UserRepository) {
        self.schedulers = schedulers
        self.clearManager = clearManager
        self.backendRepository = backendRepository
        self.userRepository = userRepository

        if let user = self.userRepository.getUser() {
            self.statusRelay = BehaviorSubject(value: .user(user))
        } else {
            self.statusRelay = BehaviorSubject(value: .guest)
        }
    }

    func fetchState() -> Observable<SessionState> {
        return self.statusRelay
            .subscribeOn(self.schedulers.background)
            .observeOn(self.schedulers.main)
    }

    func signIn(login: String, password: String, code: String) -> Single<User> {
        return Single.deferred { [unowned self] in
            let request = LoginRequest(login: login,
                                       password: password,
                                       code: code)
            return self.backendRepository
                .request(request)
                .flatMap { [unowned self] data in
                    if data.error == nil || data.key == .authorized {
                        let request = UserRequest()
                        return self.backendRepository
                            .request(request)
                    }
                    return .error(AppError.server(message: L10n.Error.authorizationFailed))
                }
                .do(onSuccess: { [unowned self] user in
                    self.userRepository.set(user: user)
                    self.statusRelay.onNext(.user(user))
                })
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func signInSocial(url: URL) -> Single<User> {
        return Single.deferred { [unowned self] in
            let request = JustURLRequest<Unit>(url: url)
            return self.backendRepository
                .request(request)
                .flatMap { [unowned self] _ in
                    let request = UserRequest()
                    return self.backendRepository
                        .request(request)
                }
                .do(onSuccess: { [unowned self] user in
                    self.userRepository.set(user: user)
                    self.statusRelay.onNext(.user(user))
                })
                .catchError { _ in
                    .error(AppError.server(message: L10n.Error.socialAuthorizationFailed))
                }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchUser() -> Single<User> {
        return Single.deferred { [unowned self] in
            let request = UserRequest()
            return self.backendRepository
                .request(request)
                .do(onSuccess: { [unowned self] user in
                    self.userRepository.set(user: user)
                })
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchSocialData() -> Single<SocialOAuthData?> {
        return Single.deferred { [unowned self] in
            if let data = self.data {
                return .just(data)
            }

            let request = SocialDataRequest()
            return self.backendRepository
                .request(request)
                .map {
                    $0.first(where: { $0.key == .vk })
                }
                .do(onSuccess: { [unowned self] item in
                    self.data = item
                })
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func forceLogout() {
        self.clearManager.clear()
        self.statusRelay.onNext(.guest)
    }

    func logout() {
        Single<Unit>.deferred { [unowned self] in
            let request = LogoutRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .subscribe()
        .disposed(by: self.bag)

        self.forceLogout()
    }
}
