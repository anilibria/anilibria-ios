import Foundation

/// Request configuration protocol
protocol BackendAPIRequest {
    associatedtype ResponseObject: Decodable
    /// Server url
    ///
    /// Example: "http://example.com"
    var baseUrl: String { get }

    /// Path of request without baseUrl and version of API
    ///
    /// Example: "users/detail"
    var endpoint: String { get }

    /// Version of API
    ///
    /// Default: ""
    var apiVersion: String { get }

    /// Network method like GET, POST and etc
    var method: NetworkManager.Method { get }

    /// Query parameters passed to request
    /// Default: empty
    var parameters: [String: Any] { get }

    /// Body passed to request
    /// Default: nil
    var body: (any Encodable)? { get }

    /// Headers passed to equest
    var headers: [String: String] { get }

    /// Converter for processing the response, if the default converter for this request does inappropriate
    /// from the configuration of BeckendService
    ///
    /// You need this, if API is shit
    ///
    /// Default: nil
    var customResponseConverter: BackendResponseConverter? { get }
}

extension BackendAPIRequest {
    var baseUrl: String {
        return Configuration.server
    }

    var apiVersion: String {
        return "api/v1"
    }

    var parameters: [String: Any] {
        return [:]
    }

    var body: (any Encodable)? {
        return nil
    }

    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }

    var customResponseConverter: BackendResponseConverter? {
        return nil
    }
}

public struct Unit: Decodable, ExpressibleByNilLiteral {
    public init() {}
    public init(nilLiteral: ()) {}
}
