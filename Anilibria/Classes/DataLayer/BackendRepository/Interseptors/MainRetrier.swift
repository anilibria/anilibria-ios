import Alamofire

public final class MainRetrier: RequestRetrier {
    weak var sessionService: SessionService?

    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let afError = error as? AFError, afError.responseCode == 401 {
            self.sessionService?.forceLogout()
        }
        completion(false, 0.0) // don't retry
    }
}
