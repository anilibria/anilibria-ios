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
        error: Error,
        retryNumber: Int,
        completion: @escaping RetryCompletion
    ) {
        switch error {
        case let AppError.network(code) where codes.contains(code):
            sessionService?.forceLogout()
        case let error as URLError where error.code == .timedOut:
            appConfig.updateBaseUrl().sink(
                onNext: { _ in completion(true) },
                onError: { _ in completion(false) }
            ).store(in: &cancellables)
        default:
            // don't retry
            completion(false)
        }
    }
}
