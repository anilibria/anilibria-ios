import DITranquillity
import Foundation
import Combine

class BackendRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(BackendRepositoryImp.init)
            .as(BackendRepository.self)
            .lifetime(.single)
    }
}

protocol BackendRepository {
    func request<T: BackendAPIRequest>(_ request: T) -> AnyPublisher<T.ResponseObject, Error>
    func request<T: BackendAPIRequest>(_ request: T, retrier: LoadRetrier) -> AnyPublisher<T.ResponseObject, Error>
    func apply(_ settings: AniSettings)
}

final class BackendRepositoryImp: BackendRepository, Loggable {
    var defaultLoggingTag: LogTag {
        return .repository
    }

    public let config: BackendConfiguration
    fileprivate let networkManager: NetworkManager

    init(config: BackendConfiguration) {
        self.config = config
        self.networkManager = NetworkManager(adapter: config.interceptor,
                                             retrier: config.retrier)
    }

    func apply(_ settings: AniSettings) {
        Configuration.apply(settings)
        self.networkManager.restartWith(proxy: settings.proxy)
    }

    func request<T: BackendAPIRequest>(_ request: T) -> AnyPublisher<T.ResponseObject, Error> {
        return self.defaultRequest(request)
            .tryMap { [unowned self] data in
                try self.convertResponse(request: request, data: data)
            }
            .eraseToAnyPublisher()
    }

    func request<T: BackendAPIRequest>(_ request: T, retrier: LoadRetrier) -> AnyPublisher<T.ResponseObject, Error> {
        return self.defaultRequest(request, retrier: retrier)
            .tryMap { [unowned self] data in
                try self.convertResponse(request: request, data: data)
            }
            .eraseToAnyPublisher()
    }

    private func defaultRequest<T: BackendAPIRequest>(
        _ request: T,
        retrier: LoadRetrier? = nil
    ) -> AnyPublisher<NetworkResponse, Error> {
        return self.networkManager.request(
            url: request.buildUrl(),
            method: request.method,
            body: request.body,
            params: request.parameters,
            headers: request.headers,
            retrier: retrier
        )
    }

    private func convertResponse<T: BackendAPIRequest>(request: T,
                                                       data: NetworkResponse) throws -> T.ResponseObject {
        var (response, error): (T.ResponseObject?, Error?)
        if let converter = request.customResponseConverter {
            (response, error) = converter.convert(T.self, response: data)
        } else {
            (response, error) = self.config.converter.convert(T.self, response: data)
        }
        if let result = response {
            return result
        } else if let e = error {
            throw e
        } else {
            throw AppError.unexpectedError(message: "empty")
        }
    }
}

fileprivate extension BackendAPIRequest {
    func buildUrl() -> URL {
        guard var url = URL(string: baseUrl) else {
            fatalError("NOT VALID STRING URL!")
        }
        if !apiVersion.isEmpty {
            url = url.appendingPathComponent(apiVersion)
        }
        return url.appendingPathComponent(endpoint)
    }
}
