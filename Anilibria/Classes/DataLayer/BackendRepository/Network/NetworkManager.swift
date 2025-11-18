import Foundation
import Combine

public typealias NetworkResponse = (data: Data, code: Int, httpResponse: HTTPURLResponse?, request: URLRequest)
open class NetworkManager: Loggable {

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    private static let requestTimeout: Double = 10
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = NetworkManager.requestTimeout * 2
        configuration.timeoutIntervalForRequest = NetworkManager.requestTimeout
        configuration.waitsForConnectivity = true
        configuration.urlCredentialStorage = nil
        configuration.httpShouldSetCookies = false

        configuration.httpAdditionalHeaders = [
            "Store-Published": "Apple",
            "User-Agent": "mobileApp iOS"
        ]
        return URLSession(configuration: configuration)
    }()

    public enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }

    func request(
        url: URL,
        method: Method,
        body: (any Encodable)? = nil,
        params: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<NetworkResponse, Error> {
        let request = createRequest(
            url: url,
            method: method,
            params: params,
            body: body,
            headers: headers
        )
        log(.debug, request.curl)
        return send(request: request)
    }

    private func send(request: URLRequest) -> AnyPublisher<NetworkResponse, Error> {
        return session.dataTaskPublisher(for: request).tryMap { (data, response) in
            let httpResponse = response as? HTTPURLResponse
            let code = httpResponse?.statusCode ?? -1
            if code != 200 {
                throw AppError.network(statusCode: code)
            }
            return NetworkResponse(data, code, httpResponse, request)
        }.eraseToAnyPublisher()
    }

    private func createRequest(
        url: URL,
        method: Method,
        params: [String: Any]?,
        body: (any Encodable)?,
        headers: [String: String]?
    ) -> URLRequest {
        var requestURL: URL = url
        let parameterString = params?.stringFromHttpParameters()
        if let values = parameterString {
            requestURL = URL(string: "\(url)?\(values)")!
        }

        var request = URLRequest(url: requestURL,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: NetworkManager.requestTimeout)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpShouldHandleCookies = false

        if let item = body, let data = try? JSONEncoder().encode(item) {
            request.httpBody = data
        }

        return request
    }
}

extension URLRequest {
    public var curl: String {
        var data : String = ""
        let complement = "\\\n"
        let method = "-X \(self.httpMethod ?? "GET") \(complement)"
        let urlAbsoluteString: String = url?.absoluteString ?? ""
        let url = "'\(urlAbsoluteString)'"

        let header = self.allHTTPHeaderFields?.reduce("", { (result, data) -> String in
            return result + "-H '\(data.key): \(data.value)' \(complement)"
        }) ?? ""

        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            data = "-d '\(bodyString)' \(complement)"
        }

        let command = "curl -i " + complement + method + header + data + url

        return command
    }
}
