import Foundation

public final class URLConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = URL?
    let base: String

    init(_ base: String) {
        if base.last == "/" {
            self.base = String(base.dropLast())
        } else {
            self.base = base
        }
    }

    public func convert(from item: String?) -> URL? {
        guard let urlString = item else {
            return nil
        }

        if urlString.hasPrefix("http") {
            return urlString.toURL()
        }

        return "\(self.base)\(urlString)".toURL()
    }
}
