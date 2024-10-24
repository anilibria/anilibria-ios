import DITranquillity
import Kingfisher
import Combine
import Foundation

final class AppConfigurationServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(AppConfigurationServiceImp.init)
            .as(AppConfigurationService.self)
            .lifetime(.single)
    }
}

protocol AppConfigurationService: AnyObject {
    func fetchState() -> AnyPublisher<ConfigurationState, Never>
    func startConfiguration() -> AnyPublisher<ConfigurationState, Error>
    func manualComplete()
}

enum ConfigurationState {
    case started
    case completed
}

final class AppConfigurationServiceImp: AppConfigurationService {
    let backendRepository: BackendRepository
    let configRepository: ConfigRepository

    var currentProxy: AniProxy? {
        didSet {
            self.updateProxy()
        }
    }
    
    private let statusRelay: CurrentValueSubject<ConfigurationState, Never> = CurrentValueSubject(.started)

    init(backendRepository: BackendRepository,
         configRepository: ConfigRepository) {
        self.backendRepository = backendRepository
        self.configRepository = configRepository
    }

    func fetchState() -> AnyPublisher<ConfigurationState, Never> {
        return self.statusRelay.eraseToAnyPublisher()
    }

    func startConfiguration() -> AnyPublisher<ConfigurationState, Error> {
        self.manualComplete()
        return .just(.completed)
    }

    func manualComplete() {
        self.backendRepository.apply(.default)
        self.currentProxy = nil
        self.statusRelay.send(.completed)
    }

    private func applySettingsAndCheck(_ settings: AniSettings) -> AnyPublisher<AniSettings, Error> {
        self.backendRepository.apply(settings)
        self.currentProxy = settings.proxy

        return self.backendRepository
            .request(CheckRequest())
            .map { _ in settings }
            .catch({ [unowned self] _ in
                if let next = settings.next {
                    return self.applySettingsAndCheck(next)
                }
                return .fail(AppConfigError.notFound)
            })
            .eraseToAnyPublisher()
    }

    func loadConfig() -> AnyPublisher<AniSettings, Error> {
        return Deferred { [unowned self] in
            let request = JustURLRequest<AniConfig>(url: URLS.config)
            return self.backendRepository
                .request(request)
                .map { [unowned self] config in
                    self.configRepository.set(config: config)
                    return config
                }
                .catch { [unowned self] _ in
                    if let config = self.configRepository.getConfig() {
                        return AnyPublisher<AniConfig, Error>.just(config)
                    }
                    return AnyPublisher<AniConfig, Error>.fail(AppConfigError.empty)
                }
                .map(AniSettings.create(from:))
                .tryMap { item -> AniSettings in
                    if let value = item {
                        return value
                    }
                    throw AppConfigError.broken
                }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    func updateProxy() {
        var proxyData: [AnyHashable : Any] = [:]
        if let proxy = self.currentProxy {
            proxyData = proxy.config()
        }
        let conf = ImageDownloader.default.sessionConfiguration
        conf.connectionProxyDictionary = proxyData
        ImageDownloader.default.sessionConfiguration = conf
    }
}

enum AppConfigError: Error {
    case empty
    case broken
    case notFound
}

extension AppConfigError: ErrorDisplayable {
    var displayMessage: String? {
        return "empty"
    }
}
