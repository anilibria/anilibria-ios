import Foundation

public final class URLConverter: Converter {
    static let base = "https://placeholder.some"
    public typealias FromValue = String?
    public typealias ToValue = URL?

    public func convert(from item: String?) -> URL? {
        guard let urlString = item else {
            return nil
        }

        if urlString.hasPrefix("http") {
            return urlString.toURL()
        }

        return "\(Self.base)\(urlString)".toURL()
    }
}
