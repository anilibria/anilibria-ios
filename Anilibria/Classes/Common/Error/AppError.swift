import Alamofire
import Foundation
import LocalAuthentication

public protocol ErrorDisplayable {
    var displayMessage: String? { get }
}

public enum AppError: Error {
    private static let errorDomain: String = "MRKitErrorDomain"

    case error(code: Int)
    case responseError(code: Int)
    case network(error: Error)
    case api(error: Error)
    case other(error: Error)
    case unexpectedError(message: String)
    case server(message: String)
}

extension AppError: ErrorDisplayable {
    public var displayMessage: String? {
        switch self {
        case let .api(error), let .network(error), let .other(error):
            return error.message
        case let .error(code), let .responseError(code):
            return "Error: \(code)"
        case let .unexpectedError(message), let .server(message):
            return message
        }
    }
}

extension AFError: ErrorDisplayable {
    public var displayMessage: String? {
        if self.responseCode == 401 {
            return L10n.Error.authorizationInvailid
        }
        return "Network \(self.responseCode ?? -1)"
    }
}

extension Error {
    var message: String {
        if let text = (self as? ErrorDisplayable)?.displayMessage {
            return text
        }
        if let text = self._userInfo?[NSLocalizedDescriptionKey] as? String {
            return text
        }
        return "\(self)"
    }
}
