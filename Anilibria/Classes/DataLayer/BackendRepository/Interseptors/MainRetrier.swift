import Foundation

final class MainRetrier: LoadRetrier {
    weak var sessionService: SessionService?

    func need(retry request: URLRequest, error: Error, retryNumber: Int, completion: @escaping RetryCompletion) {
        if case let .network(code) = error as? AppError, code == 401 {
            self.sessionService?.forceLogout()
        }
        completion(false) // don't retry
    }
}
