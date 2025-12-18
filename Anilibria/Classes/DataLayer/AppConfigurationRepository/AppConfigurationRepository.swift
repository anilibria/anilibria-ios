import DITranquillity
import Kingfisher
import Combine
import Foundation

final class AppConfigurationRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(AppConfigurationRepositoryImp.init)
            .as(AppConfigurationRepository.self)
            .lifetime(.single)
    }
}

protocol AppConfigurationRepository: AnyObject {
    func fetchBaseImageUrl() -> AnyPublisher<URL, any Error>
    func fetchBaseUrl() -> AnyPublisher<URL, Error>
    func updateBaseUrl() -> AnyPublisher<URL, Error>
}

final class AppConfigurationRepositoryImp: AppConfigurationRepository {
    private let baseUrlProvider: BaseUrlProvider

    init(configRepository: ConfigRepository) {
        baseUrlProvider = BaseUrlProvider(configRepository: configRepository)
    }

    func fetchBaseImageUrl() -> AnyPublisher<URL, any Error> {
        return AnyPublisher.create(asyncFunc: { [unowned self] in
            return await baseUrlProvider.baseImageUrl
        })
        .flatMap { [unowned self] url -> AnyPublisher<URL, any Error> in
            if let url {
                .just(url)
            } else {
                updateBaseUrl()
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchBaseUrl() -> AnyPublisher<URL, any Error> {
        return AnyPublisher.create(asyncFunc: { [unowned self] in
            return await baseUrlProvider.baseUrl
        })
        .flatMap { [unowned self] url -> AnyPublisher<URL, any Error> in
            return if let url {
                .just(url)
            } else {
                updateBaseUrl()
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func updateBaseUrl() -> AnyPublisher<URL, any Error> {
        AnyPublisher.create { [unowned self] in
            if !(await baseUrlProvider.isOutdated) {
                await baseUrlProvider.extractAlternative()
            } else {
                do {
                    let (data, _) = try await URLSession.shared.data(from: URLS.config)
                    let config = try JSONDecoder().decode(AniConfig.self, from: data)
                    await baseUrlProvider.update(with: config)
                } catch(let error) {
                    if await baseUrlProvider.containsAlternative() {
                        await baseUrlProvider.extractAlternative()
                    } else {
                        throw error
                    }
                }
            }
        }
        .flatMap { [unowned self] in
            fetchBaseUrl()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

actor BaseUrlProvider {
    private let configRepository: ConfigRepository

    private var currentConfigData: AniConfigInfo
    private var infoItem: AniConfigInfo.Item?

    var baseUrl: URL? {
        infoItem?.address.baseUrl
    }

    var baseImageUrl: URL? {
        infoItem?.address.baseImagesUrl
    }

    var isOutdated: Bool {
        currentConfigData.isOutdated
    }

    init(configRepository: ConfigRepository) {
        self.configRepository = configRepository
        currentConfigData = configRepository.getConfig()
        infoItem = currentConfigData.topPriorityItem()
    }

    func update(with config: AniConfig) {
        currentConfigData.update(with: config)
        configRepository.set(config: currentConfigData)
        infoItem = currentConfigData.topPriorityItem()
    }

    func containsAlternative() -> Bool {
        currentConfigData.items.count > 1
    }

    func extractAlternative() {
        guard var item = infoItem else { return }
        let count = currentConfigData.items.count
        currentConfigData.items.remove(item)
        item.priority -= count
        currentConfigData.items.insert(item)
        infoItem = currentConfigData.topPriorityItem()
    }
}
