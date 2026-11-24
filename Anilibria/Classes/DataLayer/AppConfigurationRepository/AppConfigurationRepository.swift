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
    func updateBaseUrl(_ baseUrl: URL?, attempts: Int) -> AnyPublisher<URL, Error>

    func fetchLinks() -> AnyPublisher<AniLinks?, any Error>
}

final class AppConfigurationRepositoryImp: AppConfigurationRepository {
    private let provider: AniConfigProvider

    init(configRepository: ConfigRepository) {
        provider = AniConfigProvider(configRepository: configRepository)
    }

    func fetchBaseImageUrl() -> AnyPublisher<URL, any Error> {
        return AnyPublisher.create(asyncFunc: { [unowned self] in
            return await provider.baseImageUrl
        })
        .flatMap { [unowned self] url -> AnyPublisher<URL, any Error> in
            if let url {
                .just(url)
            } else {
                updateBaseUrl(nil, attempts: 0)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchBaseUrl() -> AnyPublisher<URL, any Error> {
        return AnyPublisher.create(asyncFunc: { [unowned self] in
            let value = await provider.baseUrl
            return value
        })
        .flatMap { [unowned self] url -> AnyPublisher<URL, any Error> in
            return if let url {
                .just(url)
            } else {
                updateBaseUrl(nil, attempts: 0)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func updateBaseUrl(_ baseUrl: URL?, attempts: Int) -> AnyPublisher<URL, any Error> {
        AnyPublisher.create { [unowned self] in
            return try await provider.next(for: baseUrl, attempts: attempts)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchLinks() -> AnyPublisher<AniLinks?, any Error> {
        AnyPublisher.create { [unowned self] in
            return await provider.getLinks()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

private actor AniConfigProvider {
    private var activeTask: Task<URL, Error>?
    private let configRepository: ConfigRepository

    private var currentConfigData: AniConfigInfo
    private var infoItem: AniConfigInfo.Item?

    private var isOutdated: Bool {
        currentConfigData.isOutdated
    }

    var baseUrl: URL? {
        infoItem?.address.baseUrl
    }

    var baseImageUrl: URL? {
        infoItem?.address.baseImagesUrl
    }

    init(configRepository: ConfigRepository) {
        self.configRepository = configRepository
        currentConfigData = configRepository.getConfig()
        infoItem = currentConfigData.topPriorityItem()
    }

    func next(for url: URL?, attempts: Int) async throws -> URL {
        guard attempts == 0 || attempts < currentConfigData.items.count else {
            throw AppError.error(code: MRKitErrorCode.noAlternative)
        }
        if let task = activeTask { return try await task.value }

        let task = Task { try await fetch(with: url) }
        activeTask = task
        defer { activeTask = nil }

        return try await task.value
    }

    func getLinks() async -> AniLinks? {
        if isOutdated {
            try? await update()
        }
        return currentConfigData.config?.urls
    }

    private func fetch(with url: URL?) async throws -> URL {
        if let baseUrl, url != baseUrl {
            return baseUrl
        }
        if isOutdated {
            do {
                try await update()
            } catch {
                try extractAlternative()
            }
        } else {
            try extractAlternative()
        }
        if let url = baseUrl {
            return url
        }
        throw AppError.error(code: MRKitErrorCode.noBaseUrl)
    }

    private func update() async throws {
        let (data, _) = try await URLSession.shared.data(from: URLS.config)
        let config = try JSONDecoder().decode(AniConfig.self, from: data)
        currentConfigData.update(with: config)
        configRepository.set(config: currentConfigData)
        infoItem = currentConfigData.topPriorityItem()
    }

    private func extractAlternative() throws {
        guard var item = infoItem else { return }
        let count = currentConfigData.items.count
        if count <= 1 {
            throw AppError.error(code: MRKitErrorCode.noAlternative)
        }
        currentConfigData.items.remove(item)
        item.priority -= count
        currentConfigData.items.insert(item)
        configRepository.set(config: currentConfigData)
        infoItem = currentConfigData.topPriorityItem()
    }
}
