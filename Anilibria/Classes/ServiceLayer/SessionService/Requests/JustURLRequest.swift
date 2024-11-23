import Foundation

public struct JustURLRequest<T: Decodable>: BackendAPIRequest {
    typealias ResponseObject = T

    private(set) var baseUrl: String = ""
    private(set) var endpoint: String = ""
    private(set) var method: NetworkManager.Method = .GET
    private(set) var parameters: [String: Any] = [:]

    init(url: URL) {
        self.baseUrl = [url.scheme, url.host]
            .compactMap { $0 }
            .joined(separator: "://")
        self.endpoint = url.relativePath

        url.query?
            .split(separator: "&")
            .map {
                $0.split(separator: "=").map(String.init)
            }
            .forEach({ values in
                self.parameters[values[0]] = values[1]
            })
    }
}
