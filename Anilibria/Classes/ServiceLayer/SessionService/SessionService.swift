import DITranquillity
import Combine
import Foundation

final class SessionServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(SessionServiceImp.init)
            .as(SessionService.self)
            .lifetime(.single)
    }
}

protocol SessionService: AnyObject {
    func fetchState() -> AnyPublisher<SessionState, Never>

    func signIn(login: String, password: String, code: String) -> AnyPublisher<User, Error>
    func signInSocial(url: URL) -> AnyPublisher<User, Error>

    func fetchUser() -> AnyPublisher<User, Error>

    func fetchSocialData() -> AnyPublisher<SocialOAuthData?, Error>

    func forceLogout()
    func logout()
}

final class SessionServiceImp: SessionService, Loggable {
    var defaultLoggingTag: LogTag { .service }
    
    let backendRepository: BackendRepository
    let userRepository: UserRepository
    let clearManager: ClearableManager

    private var bag = Set<AnyCancellable>()
    private var data: SocialOAuthData?

    private let statusRelay: CurrentValueSubject<SessionState, Never>

    init(clearManager: ClearableManager,
         backendRepository: BackendRepository,
         userRepository: UserRepository) {
        self.clearManager = clearManager
        self.backendRepository = backendRepository
        self.userRepository = userRepository

        if let user = self.userRepository.getUser() {
            self.statusRelay = CurrentValueSubject(.user(user))
        } else {
            self.statusRelay = CurrentValueSubject(.guest)
        }
    }

    func fetchState() -> AnyPublisher<SessionState, Never> {
        return self.statusRelay
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func signIn(login: String, password: String, code: String) -> AnyPublisher<User, Error> {
        return Deferred { [unowned self] in
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
                    return AnyPublisher<User, Error>.fail(AppError.server(message: L10n.Error.authorizationFailed))
                }
                .do(onNext: { [unowned self] user in
                    self.userRepository.set(user: user)
                    self.statusRelay.send(.user(user))
                })
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func signInSocial(url: URL) -> AnyPublisher<User, Error> {
        return Deferred<AnyPublisher<User, Error>> { [unowned self] in
            let request = JustURLRequest<Unit>(url: url)
            return self.backendRepository
                .request(request)
                .flatMap { [unowned self] _ in
                    let request = UserRequest()
                    return self.backendRepository
                        .request(request)
                }
                .do(onNext: { [unowned self] user in
                    self.userRepository.set(user: user)
                    self.statusRelay.send(.user(user))
                })
                .mapError { [weak self] in
                    self?.log(.error, $0.localizedDescription)
                    return AppError.server(message: L10n.Error.socialAuthorizationFailed)
                }
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchUser() -> AnyPublisher<User, Error> {
        return Deferred { [unowned self] in
            let request = UserRequest()
            return self.backendRepository
                .request(request)
                .do(onNext: { [unowned self] user in
                    self.userRepository.set(user: user)
                })
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchSocialData() -> AnyPublisher<SocialOAuthData?, Error> {
        return Deferred<AnyPublisher<SocialOAuthData?, Error>> { [unowned self] in
            if let data = self.data {
                return AnyPublisher<SocialOAuthData?, Error>.just(data)
            }

            let request = SocialDataRequest()
            return self.backendRepository
                .request(request)
                .map {
                    $0.first(where: { $0.key == .vk })
                }
                .do(onNext: { [unowned self] item in
                    self.data = item
                })
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func forceLogout() {
        self.clearManager.clear()
        self.statusRelay.send(.guest)
    }

    func logout() {
        Deferred { [unowned self] in
            let request = LogoutRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .sink()
        .store(in: &bag)

        self.forceLogout()
    }
}
