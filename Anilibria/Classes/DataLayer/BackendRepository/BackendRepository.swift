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
}

final class BackendRepositoryImp: BackendRepository, Loggable {
    var defaultLoggingTag: LogTag {
        return .repository
    }

    private let config: BackendConfiguration
    private let appConfig: AppConfigurationRepository
    fileprivate let networkManager: NetworkManager = NetworkManager()

    private var retrier: (any LoadRetrier)? {
        config.retrier
    }

    private var modifier: AsyncRequestModifier? {
        config.interceptor
    }

    init(config: BackendConfiguration,
         appConfig: AppConfigurationRepository) {
        self.config = config
        self.appConfig = appConfig
    }

    func request<T: BackendAPIRequest>(_ request: T) -> AnyPublisher<T.ResponseObject, Error> {
        return self.runWithModifier(request: request, retrier: retrier)
            .tryMap { [unowned self] data in
                return try self.convertResponse(request: request, data: data)
            }
            .eraseToAnyPublisher()
    }

    func request<T: BackendAPIRequest>(_ request: T, retrier: LoadRetrier) -> AnyPublisher<T.ResponseObject, Error> {
        return self.runWithModifier(request: request, retrier: retrier)
            .tryMap { [unowned self] data in
                try self.convertResponse(request: request, data: data)
            }
            .eraseToAnyPublisher()
    }

    private func runWithModifier(
        request: any BackendAPIRequest,
        retrier: LoadRetrier?,
    ) -> AnyPublisher<NetworkResponse, Error> {
        return Deferred<Future<any BackendAPIRequest, Error>> {
            Future<any BackendAPIRequest, Error> { [weak self] promise in
                if let modifier = self?.modifier {
                    modifier.modify(request) {
                        promise(.success($0))
                    }
                } else {
                    promise(.success(request))
                }
            }
        }
        .flatMap { [unowned self] in
            run(request: $0, retrier: retrier)
        }
        .eraseToAnyPublisher()
    }


    private func run(
        request: any BackendAPIRequest,
        retrier: LoadRetrier?,
        retryNumber: Int = 0
    ) -> AnyPublisher<NetworkResponse, Error> {
        func run(with base: URL?) -> AnyPublisher<NetworkResponse, Error> {
            networkManager.request(
                url: request.buildUrl(base: base),
                method: request.requestData.method,
                body: request.requestData.body,
                params: request.requestData.parameters,
                headers: request.requestData.headers
            ).catch { [unowned self] error -> AnyPublisher<NetworkResponse, Error> in
                guard let retrier else { return .fail(error) }
                return retry(
                    request: request,
                    with: retrier,
                    error: error,
                    retryNumber: retryNumber
                )
            }
            .eraseToAnyPublisher()
        }
        if let url = request.requestData.baseUrl {
            return run(with: URL(string: url))
        }

        return appConfig.fetchBaseUrl()
            .flatMap(run(with:))
            .eraseToAnyPublisher()
    }

    private func retry(
        request: any BackendAPIRequest,
        with retrier: LoadRetrier,
        error: Error,
        retryNumber: Int
    ) -> AnyPublisher<NetworkResponse, Error> {
        Deferred<Future<Void, Error>> {
            Future<Void, Error> { promise in
                retrier.need(retry: request, error: error, retryNumber: retryNumber) { needToRetry in
                    if needToRetry {
                        promise(.success(()))
                    } else {
                        promise(.failure(error))
                    }
                }
            }
        }
        .flatMap { [unowned self] in
            run(
                request: request,
                retrier: retrier,
                retryNumber: retryNumber + 1
            )
        }
        .eraseToAnyPublisher()
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
            throw AppError.plain(message: "empty response")
        }
    }
}

fileprivate extension BackendAPIRequest {
    func buildUrl(base url: URL?) -> URL {
        guard var url = url else {
            fatalError("NOT VALID STRING URL!")
        }
        if !requestData.apiVersion.isEmpty {
            url = url.appendingPathComponent(requestData.apiVersion)
        }
        if !requestData.endpoint.isEmpty {
            url = url.appendingPathComponent(requestData.endpoint)
        }
        return url
    }
}
