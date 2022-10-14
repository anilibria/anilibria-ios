import DITranquillity
import Kingfisher
import RxSwift

final class AppConfigurationServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(AppConfigurationServiceImp.init)
            .as(AppConfigurationService.self)
            .lifetime(.single)
    }
}

protocol AppConfigurationService: AnyObject {
    func fetchState() -> Observable<ConfigurationState>
    func startConfiguration() -> Single<ConfigurationState>
    func manualComplete()
}

enum ConfigurationState {
    case started
    case completed
}

final class AppConfigurationServiceImp: AppConfigurationService {
    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository
    let configRepository: ConfigRepository

    var currentProxy: AniProxy?
    private let statusRelay: BehaviorSubject<ConfigurationState> = BehaviorSubject(value: .started)

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository,
         configRepository: ConfigRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
        self.configRepository = configRepository
        ImageDownloader.default.delegate = self
    }

    func fetchState() -> Observable<ConfigurationState> {
        return self.statusRelay
    }

    func startConfiguration() -> Single<ConfigurationState> {
        return self.loadConfig()
            .flatMap { [unowned self] in
                if let old = self.configRepository.getCurrentSettings() {
                    old.next = $0
                    return self.applySettingsAndCheck(old)
                }
                return self.applySettingsAndCheck($0)
            }
            .do(onSuccess: { [unowned self] settings in
                self.configRepository.setCurrent(settings: settings)
            })
            .map { _ in ConfigurationState.completed }
            .observeOn(self.schedulers.main)
            .do(onSuccess: { [weak self] state in
                self?.statusRelay.onNext(state)
            })
    }

    func manualComplete() {
        self.backendRepository.apply(.default)
        self.currentProxy = nil
        self.updateProxy()
        self.statusRelay.onNext(.completed)
    }

    private func applySettingsAndCheck(_ settings: AniSettings) -> Single<AniSettings> {
        self.backendRepository.apply(settings)
        self.currentProxy = settings.proxy
        self.updateProxy()

        return self.backendRepository
            .request(CheckRequest())
            .map { _ in settings }
            .catchError({ [unowned self] _ in
                if let next = settings.next {
                    return self.applySettingsAndCheck(next)
                }
                return .error(AppConfigError.notFound)
            })
    }

    func loadConfig() -> Single<AniSettings> {
        return Single.deferred { [unowned self] in
            let request = JustURLRequest<AniConfig>(url: URLS.config)
            return self.backendRepository
                .request(request)
                .map { [unowned self] config in
                    self.configRepository.set(config: config)
                    return config
                }
                .catchError { [unowned self] _ in
                    if let config = self.configRepository.getConfig() {
                        return .just(config)
                    }
                    return .error(AppConfigError.empty)
                }
                .map(AniSettings.create(from:))
                .flatMap { item -> Single<AniSettings> in
                    if let value = item {
                        return .just(value)
                    }
                    return .error(AppConfigError.broken)
                }
        }
        .subscribeOn(self.schedulers.background)
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
