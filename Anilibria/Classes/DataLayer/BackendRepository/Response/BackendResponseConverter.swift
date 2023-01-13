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

        let model = try? JSONDecoder().decode(ApiResponse<T.ResponseObject>.self, from: data.0)

        if let responseData = model?.data {
            return (responseData, nil)
        } else if let error = model?.error {
            return (nil, AppError.api(error: error))
        } else {
            self.log(.error, "Error parsing request: \(data.3)")
            let text = String(data: data.0, encoding: .utf8) ?? ""
            self.log(.error, text)
            return (nil, AppError.responseError(code: MRKitErrorCode.parsingError))
        }
    }
}

public final class ApiResponse<T: Decodable>: Decodable {
    var status: Bool = true
    var data: T?
    var error: ApiError?

    public init(from decoder: Decoder) throws {
        self.status <- decoder["status"]
		self.data <- decoder["data"]
		self.error <- decoder["error"]

        if self.data == nil,
            let type = T.self as? ExpressibleByNilLiteral.Type,
            let result = type.init(nilLiteral: ()) as? T {
            self.data = result
        }
    }
}

public class FullDataResponseConverter: BackendResponseConverter, Loggable {
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

        let model = try? JSONDecoder().decode(T.ResponseObject.self, from: data.0)

        if let responseData = model {
            return (responseData, nil)
        } else if let type = T.ResponseObject.self as? ExpressibleByNilLiteral.Type,
            let result = type.init(nilLiteral: ()) as? T.ResponseObject {
            return (result, nil)
        } else {
            self.log(.error, "Error parsing request: \(data.3)")
            let text = String(data: data.0, encoding: .utf8) ?? ""
            self.log(.error, text)
            return (nil, AppError.responseError(code: MRKitErrorCode.parsingError))
        }
    }
}
