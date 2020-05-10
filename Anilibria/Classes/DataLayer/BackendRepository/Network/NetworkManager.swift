import Alamofire
import Foundation
import RxSwift

open class NetworkManager: Loggable {
    public typealias MultiPartData = (item: Data, fileName: String, mimeType: String)
    public typealias NetworkResponse = (Data, Int, HTTPURLResponse?, URLRequest?)

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    private static let requestTimeout: Double = 10
    private var task: URLSessionTask?
    private var manager: SessionManager!

    public enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }

    init(adapter: RequestAdapter?,
         retrier: RequestRetrier?) {
        self.manager = SessionManager(configuration: self.configuration())
        self.manager.adapter = adapter
        self.manager.retrier = retrier
    }

    func restartWith(proxy: AniProxy?) {
        let old = self.manager
        self.manager = SessionManager(configuration: self.configuration(proxy: proxy))
        self.manager.adapter = old!.adapter
        self.manager.retrier = old!.retrier
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
                 headers: [String: String]? = nil) -> Single<NetworkResponse> {
        return Single.deferred({ [unowned self] () -> Single<NetworkResponse> in
            let request = self.createRequest(url: url,
                                             method: method,
                                             params: params,
                                             headers: headers)

            return Single.create(subscribe: { [unowned self] (observer) -> Disposable in
                let request = self.manager.request(request)
                self.task = request.task

                request
                    .validate()
                    .response(completionHandler: { response in
                        if let error = response.error {
                            observer(.error(AppError.network(error: error)))
                        } else if response.response != nil {
                            observer(.success((response.data!,
                                               response.response!.statusCode,
                                               response.response,
                                               response.request)))
                        } else {
                            observer(.error(AppError.responseError(code: MRKitErrorCode.unknownNetworkError)))
                        }
                    })
                self.log(.debug, request.debugDescription)
                return Disposables.create()
            }).retry(1)
        })
    }

    func createRequest(url: URL,
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
        return request
    }

    func cancel() {
        self.task?.cancel()
    }
}
