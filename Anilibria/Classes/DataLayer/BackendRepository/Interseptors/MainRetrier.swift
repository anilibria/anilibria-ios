import Foundation
import Combine

final class MainRetrier: LoadRetrier {
    weak var sessionService: SessionService?
    private let appConfig: AppConfigurationRepository
    private let codes: [Int] = [401, 403]
    private var cancellables: Set<AnyCancellable> = []

    init(appConfig: AppConfigurationRepository) {
        self.appConfig = appConfig
    }

    func need(
        retry request: any BackendAPIRequest,
        baseURL: URL?,
        error: Error,
        retryNumber: Int,
        completion: @escaping RetryCompletion
    ) {
        switch error {
        case let AppError.network(code) where codes.contains(code):
            sessionService?.forceLogout()
            completion(false)
        case let error as URLError where [
            .timedOut,
            .networkConnectionLost,
            .cannotFindHost,
            .cannotConnectToHost,
            .badServerResponse,
            .cannotParseResponse,
            .resourceUnavailable
        ].contains(error.code):
            appConfig.updateBaseUrl(baseURL).sink(
                onNext: { _ in completion(true) },
                onError: { _ in completion(false) }
            ).store(in: &cancellables)
        default:
            // don't retry
            completion(false)
        }
    }
}
