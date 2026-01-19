import Foundation

public enum MRKitErrorCode: Int {
    /// Unknown network error
    case unknownNetworkError = 10000
    /// No alternative base urls
    case noAlternative = 10300
    /// No base urls
    case noBaseUrl = 10301
    /// Empty response from server
    case emptyResponse = 10400
    /// Error parsing response
    case parsingError = 10401
    /// unexpected
    case unexpected = 10500
}
