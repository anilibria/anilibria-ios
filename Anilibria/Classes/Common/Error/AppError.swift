import Foundation
import LocalAuthentication

public protocol ErrorDisplayable {
    var displayMessage: String? { get }
}

public enum AppError: Error {
    private static let errorDomain: String = "MRKitErrorDomain"

    case error(code: Int)
    case network(statusCode: Int)
    case other(error: Error)
    case plain(message: String)
}

extension AppError: ErrorDisplayable {
    public var displayMessage: String? {
        switch self {
        case let .other(error):
            return error.message
        case let .error(code):
            return "Error: \(code)"
        case let .network(code):
            switch code {
            case 403: return L10n.Error.authorizationInvailid
            case 401: return L10n.Error.authorizationFailed
            default: return "Network Error: \(code)"
            }
        case let .plain(message):
            return message
        }
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
