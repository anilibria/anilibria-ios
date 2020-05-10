import DITranquillity
import Foundation
import RxSwift

class BackendRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(BackendRepositoryImp.init)
            .as(BackendRepository.self)
            .lifetime(.single)
    }
}

protocol BackendRepository {
    func request<T: BackendAPIRequest>(_ request: T) -> Single<T.ResponseObject>
    func apply(_ settings: AniSettings)
}

final class BackendRepositoryImp: BackendRepository, Loggable {
    var defaultLoggingTag: LogTag {
        return .repository
    }

    public let config: BackendConfiguration
    fileprivate let networkManager: NetworkManager!

    init(config: BackendConfiguration) {
        self.config = config
        self.networkManager = NetworkManager(adapter: config.interceptor,
                                             retrier: config.retrier)
    }

    func apply(_ settings: AniSettings) {
        Configuration.apply(settings)
        self.networkManager.restartWith(proxy: settings.proxy)
    }

    func request<T: BackendAPIRequest>(_ request: T) -> Single<T.ResponseObject> {
        return self.createSequence(for: request)
            .flatMap { [unowned self] data -> Single<T.ResponseObject> in
                self.convertResponse(request: request, data: data)
            }
    }

    private func createSequence<T: BackendAPIRequest>(for request: T) -> Single<NetworkManager.NetworkResponse> {
        if request.multiPartData?.isEmpty == false {
            fatalError("not implemented")
        } else {
            return self.defaultRequest(request)
        }
    }

    private func defaultRequest<T: BackendAPIRequest>(_ request: T) -> Single<NetworkManager.NetworkResponse> {
        return self.networkManager.request(url: request.buildUrl(),
                                           method: request.method,
                                           params: request.parameters,
                                           headers: request.headers)
    }

    private func convertResponse<T: BackendAPIRequest>(request: T,
                                                       data: NetworkManager.NetworkResponse) -> Single<T.ResponseObject> {
        return Single.deferred { [unowned self] in
            var (response, error): (T.ResponseObject?, Error?)
            if let converter = request.customResponseConverter {
                (response, error) = converter.convert(T.self, response: data)
            } else {
                (response, error) = self.config.converter.convert(T.self, response: data)
            }
            if let result = response {
                return Single.just(result)
            } else if let e = error {
                return Single.error(e)
            } else {
                return Single.error(AppError.unexpectedError(message: "empty"))
            }
        }
    }

    public func cancel() {
        self.networkManager.cancel()
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
