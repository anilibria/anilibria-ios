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
                                       response: NetworkResponse) -> (T.ResponseObject?, Error?)
}

public class JsonResponseConverter: BackendResponseConverter, Loggable {
    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    func convert<T: BackendAPIRequest>(_ type: T.Type,
                                       response: NetworkResponse) -> (T.ResponseObject?, Error?) {
        do {
            if T.ResponseObject.self == Data.self {
                return (response.data as? T.ResponseObject, nil)
            }
            let responseData = try JSONDecoder().decode(T.ResponseObject.self, from: response.data)
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
