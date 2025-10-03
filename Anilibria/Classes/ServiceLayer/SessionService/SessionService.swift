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
    func fetchState() -> AnyPublisher<SessionState?, Never>

    func signIn(login: String, password: String) -> AnyPublisher<User, Error>
    func signIn(with data: AuthProviderData) -> AnyPublisher<User, Error>
    func getDataFor(provider: AuthProvider) -> AnyPublisher<AuthProviderData, Error>

    func fetchUser() -> AnyPublisher<User, Error>

    func accept(otp code: String) -> AnyPublisher<Void, Error>

    func forceLogout()
    func logout()

    func forgetPassword(email: String) -> AnyPublisher<Void, Error>
    func resetPassword(token: String, password: String) -> AnyPublisher<Void, Error>
}

final class SessionServiceImp: SessionService, Loggable {
    var defaultLoggingTag: LogTag { .service }
    
    private let backendRepository: BackendRepository
    private let userRepository: UserRepository
    private let tokenRepository: TokenRepository
    private let clearManager: ClearableManager

    private var bag = Set<AnyCancellable>()

    private let statusRelay = CurrentValueSubject<SessionState?, Never>(nil)

    init(clearManager: ClearableManager,
         backendRepository: BackendRepository,
         userRepository: UserRepository,
         tokenRepository: TokenRepository) {
        self.clearManager = clearManager
        self.backendRepository = backendRepository
        self.userRepository = userRepository
        self.tokenRepository = tokenRepository
    }

    func fetchState() -> AnyPublisher<SessionState?, Never> {
        return tokenRepository.getToken().flatMap { [unowned self] value -> AnyPublisher<SessionState?, Never> in
            if value == nil {
                statusRelay.send(.guest)
                return getStatusRelay()
            }
            if let user = userRepository.getUser() {
                statusRelay.send(.user(user))
                return getStatusRelay()
            }
            return backendRepository
                .request(UserRequest())
                .map { user -> User? in return user }
                .catch { [unowned self] _ -> AnyPublisher<User?, Never> in
                    forceLogout()
                    return .just(nil)
                }
                .flatMap { [unowned self] user -> AnyPublisher<SessionState?, Never> in
                    if let user {
                        statusRelay.send(.user(user))
                    } else {
                        statusRelay.send(.guest)
                    }

                    return getStatusRelay()
                }
                .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func getStatusRelay() -> AnyPublisher<SessionState?, Never> {
        statusRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func signIn(login: String, password: String) -> AnyPublisher<User, Error> {
        return Deferred { [unowned self] in
            let request = LoginRequest(login: login, password: password)
            return self.backendRepository
                .request(request)
                .flatMap { [unowned self] data in
                    self.tokenRepository.set(token: data.token)
                    return self.backendRepository.request(UserRequest())
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

    func getDataFor(provider: AuthProvider) -> AnyPublisher<AuthProviderData, Error> {
        return Deferred { [unowned self] in
            let request = AuthProviderDataRequest(provider: provider)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func signIn(with data: AuthProviderData) -> AnyPublisher<User, Error> {
        return Deferred { [unowned self] in
            let request = LoginRequest(provider: data)
            return self.backendRepository
                .request(request, retrier: SimpleRetrier { error, _, completion in
                    if case let .network(code) = error as? AppError, code == 404 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            completion(true)
                        })
                    } else {
                        completion(false)
                    }
                })
                .flatMap { [unowned self] data in
                    self.tokenRepository.set(token: data.token)
                    return self.backendRepository.request(UserRequest())
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

    func accept(otp code: String) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = AcceptOTPRequest(code: code)
            return self.backendRepository
                .request(request)
                .map { _ in }
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

    func forgetPassword(email: String) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = ForgotPasswordRequest(email: email)
            return self.backendRepository
                .request(request)
                .map { _ in }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func resetPassword(token: String, password: String) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = ResetPasswordRequest(token: token, password: password)
            return self.backendRepository
                .request(request)
                .map { _ in }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
