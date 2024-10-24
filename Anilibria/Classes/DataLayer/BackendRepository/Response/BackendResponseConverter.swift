import Foundation

/// Protocol of convert NetworkResponse to pair (ResponseData?, Error?).
///
/// This protocol required for initialisation of BackendConfiguration
/// and response processing
///
/// For example see JsonResponseConverter
protocol BackendResponseConverter: AnyObject {
    /// Convert NetworkResponse to pair (ResponseData?, Error?)
    /// - parameter data: Response from NetworkService
    /// - returns: (ResponseData?, Error?)
    func convert<T: BackendAPIRequest>(_ type: T.Type,
                                       response data: NetworkResponse) -> (T.ResponseObject?, Error?)
}

public class JsonResponseConverter: BackendResponseConverter, Loggable {
    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    func convert<T: BackendAPIRequest>(_ type: T.Type,
                                       response data: NetworkResponse) -> (T.ResponseObject?, Error?) {
        if (data.0 as NSData).length == 0 {
            return (nil, AppError.responseError(code: MRKitErrorCode.emptyResponse))
        }

        if let fields = data.2?.allHeaderFields as? [String : String],
            let url = data.2?.url {
            let coockies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            for cookie in coockies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }

        do {
            let responseData = try JSONDecoder().decode(T.ResponseObject.self, from: data.0)
            return (responseData, nil)
        } catch {
            if let type = T.ResponseObject.self as? ExpressibleByNilLiteral.Type,
                let result = type.init(nilLiteral: ()) as? T.ResponseObject {
                return (result, nil)
            } else {
                self.log(.error, "Error parsing request: \(error)")
                return (nil, AppError.responseError(code: MRKitErrorCode.parsingError))
            }
        }
    }
}
