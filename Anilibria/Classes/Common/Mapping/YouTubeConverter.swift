import Foundation

public final class YouTubeConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = URL?
    private static let ytubePrefix: String = "https://www.youtube.com/watch?v="

    public func convert(from item: String?) -> URL? {
        guard let urlString = item else {
            return nil
        }

        if urlString.hasPrefix("http") {
            return urlString.toURL()
        }

        return "\(self|.ytubePrefix)\(urlString)".toURL()
    }
}
