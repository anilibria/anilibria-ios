import DITranquillity
import Kingfisher
import Combine

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

    var currentProxy: AniProxy?
    private let statusRelay: CurrentValueSubject<ConfigurationState, Never> = CurrentValueSubject(.started)

    init(backendRepository: BackendRepository,
         configRepository: ConfigRepository) {
        self.backendRepository = backendRepository
        self.configRepository = configRepository
        ImageDownloader.default.delegate = self

    }

    func fetchState() -> AnyPublisher<ConfigurationState, Never> {
        return self.statusRelay.eraseToAnyPublisher()
    }

    func startConfiguration() -> AnyPublisher<ConfigurationState, Error> {
        return self.loadConfig()
            .flatMap { [unowned self] in
                if let old = self.configRepository.getCurrentSettings() {
                    old.next = $0
                    return self.applySettingsAndCheck(old)
                }
                return self.applySettingsAndCheck($0)
            }
            .do(onNext: { [unowned self] settings in
                self.configRepository.setCurrent(settings: settings)
            })
            .map { _ in ConfigurationState.completed }
            .receive(on: DispatchQueue.main)
            .do(onNext: { [weak self] state in
                self?.statusRelay.send(state)
            })
            .eraseToAnyPublisher()
    }

    func manualComplete() {
        self.backendRepository.apply(.default)
        self.currentProxy = nil
        self.updateProxy()
        self.statusRelay.send(.completed)
    }

    private func applySettingsAndCheck(_ settings: AniSettings) -> AnyPublisher<AniSettings, Error> {
        self.backendRepository.apply(settings)
        self.currentProxy = settings.proxy
        self.updateProxy()

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
}

extension AppConfigurationServiceImp: ImageDownloaderDelegate {
    func updateProxy() {
        var proxyData: [AnyHashable : Any] = [:]
        if let proxy = self.currentProxy {
            proxyData = proxy.config()
        }
        let conf = ImageDownloader.default.sessionConfiguration
        conf.connectionProxyDictionary = proxyData
        ImageDownloader.default.sessionConfiguration = conf
    }

    public func imageDownloader(_ downloader: ImageDownloader,
                                didFinishDownloadingImageForURL url: URL,
                                with response: URLResponse?,
                                error: Error?) {
        self.updateProxy()
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
