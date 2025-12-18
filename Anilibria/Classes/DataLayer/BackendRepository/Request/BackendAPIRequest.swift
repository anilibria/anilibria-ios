import Foundation

struct RequestData {
    /// Server url
    ///
    /// Example: "http://example.com"
    var baseUrl: String? = nil

    /// Path of request without baseUrl and version of API
    ///
    /// Example: "users/detail"
    var endpoint: String = ""

    /// Version of API
    ///
    /// Default: "api/v1"
    var apiVersion: String = "api/v1"

    /// Network method like GET, POST and etc
    var method: NetworkManager.Method = .GET

    /// Query parameters passed to request
    /// Default: empty
    var parameters: [String: Any] = [:]

    /// Body passed to request
    /// Default: nil
    var body: (any Encodable)?

    /// Headers passed to equest
    var headers: [String: String] = ["Content-Type": "application/json"]
}

/// Request configuration protocol
protocol BackendAPIRequest {
    associatedtype ResponseObject: Decodable
    var requestData: RequestData { get set }
    var customResponseConverter: BackendResponseConverter? { get }
}

extension BackendAPIRequest {
    var customResponseConverter: BackendResponseConverter? { nil }
}

public struct Unit: Decodable, ExpressibleByNilLiteral {
    public init() {}
    public init(nilLiteral: ()) {}
}
