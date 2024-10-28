import Foundation

/// Configuration of BackendService
final class BackendConfiguration {
    /// Default server response converter
    var converter: BackendResponseConverter

    /// It intercept all requests before execute
    /// Example, you can pass token here
    var interceptor: AsyncRequestModifier?

    /// It intercept error for retry request
    var retrier: LoadRetrier?

    /// Initialisation of BackendConfiguration
    /// - parameter holder: API Server Url holder
    /// - parameter converter: Server response converter
    /// - parameter interceptor: It intercept all requests before execute
    /// - parameter retrier: It intercept error for retry request
    public init(converter: BackendResponseConverter,
                interceptor: AsyncRequestModifier? = nil,
                retrier: LoadRetrier? = nil) {
        self.converter = converter
        self.interceptor = interceptor
        self.retrier = retrier
    }
}
