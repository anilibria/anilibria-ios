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

    /// Parameters passed to equest
    /// Default: empty
    var parameters: [String: Any] { get }

    /// Headers passed to equest
    /// Default: empty
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
        return ""
    }

    var parameters: [String: Any] {
        return [:]
    }

    var headers: [String: String] {
        return [:]
    }

    var customResponseConverter: BackendResponseConverter? {
        return nil
    }
}

public struct Unit: Decodable, ExpressibleByNilLiteral {
    public init() {}
    public init(nilLiteral: ()) {}
}
