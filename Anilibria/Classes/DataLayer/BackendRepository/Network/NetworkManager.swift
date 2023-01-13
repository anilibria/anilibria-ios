import Foundation
import Combine

public typealias NetworkResponse = (Data, Int, HTTPURLResponse?, URLRequest)
open class NetworkManager: Loggable {

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    private static let requestTimeout: Double = 10
    private var session: URLSession!
    private let adapter: RequestModifier?
    private let retrier: LoadRetrier?

    public enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }

    init(adapter: RequestModifier?,
         retrier: LoadRetrier?) {
        self.adapter = adapter
        self.retrier = retrier
        self.session = URLSession(configuration: self.configuration())
    }

    func restartWith(proxy: AniProxy?) {
        self.session = URLSession(configuration: self.configuration(proxy: proxy))
    }

    fileprivate func configuration(proxy: AniProxy? = nil) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = NetworkManager.requestTimeout * 2
        configuration.timeoutIntervalForRequest = NetworkManager.requestTimeout
        configuration.waitsForConnectivity = true
        configuration.urlCredentialStorage = nil

        if let proxy = proxy {
            configuration.connectionProxyDictionary = proxy.config()
        }

        configuration.httpAdditionalHeaders = [
            "Store-Published": "Apple",
            "User-Agent": "mobileApp iOS"
        ]
        return configuration
    }

    func request(url: URL,
                 method: Method,
                 params: [String: Any]? = nil,
                 headers: [String: String]? = nil) -> AnyPublisher<NetworkResponse, Error> {

        let request = self.createRequest(url: url, method: method, params: params, headers: headers)
        self.log(.debug, request.curl)

        var retryNumber = 0
        return send(request: request)
            .catch { [unowned self] error -> AnyPublisher<NetworkResponse, Error> in
                guard let retrier = self.retrier else { return .fail(error) }
                defer { retryNumber += 1 }
                return self.retry(with: retrier, request: request, error: error, retryNumber: retryNumber)
            }.eraseToAnyPublisher()
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

    private func retry(with retrier: LoadRetrier,
                       request: URLRequest,
                       error: Error,
                       retryNumber: Int) -> AnyPublisher<NetworkResponse, Error> {
        Deferred<Future<Void, Error>> {
            Future<Void, Error> { promise in
                retrier.need(retry: request, error: error, retryNumber: retryNumber) { needToRetry in
                    if needToRetry {
                        promise(.success(()))
                    } else {
                        promise(.failure(error))
                    }
                }
            }
        }
        .flatMap { [unowned self] in
            self.send(request: request)
        }
        .eraseToAnyPublisher()
    }

    private func createRequest(url: URL,
                               method: Method,
                               params: [String: Any]?,
                               headers: [String: String]?) -> URLRequest {
        var requestURL: URL = url
        let parameterString = params?.stringFromHttpParameters()
        var bodyData: Data?
        if let values = parameterString {
            if method == .GET {
                requestURL = URL(string: "\(url)?\(values)")!
            } else {
                bodyData = values.data(using: .utf8)
            }
        }

        var request = URLRequest(url: requestURL,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: NetworkManager.requestTimeout)
        let cookies = HTTPCookieStorage.shared.cookies
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies!)

        let result = headers?.merging(cookieHeaders, uniquingKeysWith: { (_, b) -> String in
            b
        })

        request.allHTTPHeaderFields = result
        request.httpMethod = method.rawValue
        request.httpShouldHandleCookies = true

        if let data = bodyData {
            request.httpBody = data
        }

        if let modifier = self.adapter {
            request = modifier.modify(request)
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
        let url = "\"\(urlAbsoluteString)\""

        let header = self.allHTTPHeaderFields?.reduce("", { (result, data) -> String in
            return result + "-H \"\(data.key): \(data.value)\" \(complement)"
        }) ?? ""

        if let bodyData = self.httpBody, let bodyString = String(data:bodyData, encoding:.utf8) {
            data = "-d \"\(bodyString)\" \(complement)"
        }

        let command = "curl -i " + complement + method + header + data + url

        return command
    }
}
