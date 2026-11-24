import Foundation

public struct Configuration {
    public static var server = "https://www.anilibria.tv"
    public static var imageServer = "https://www.anilibria.tv"
    public static var widgetServer = "https://www.anilibria.tv"

    /// Applies base urls obtained from the API v2 app configuration (gist config.json).
    public static func apply(baseUrl: URL?, baseImageUrl: URL?) {
        if let baseUrl {
            server = baseUrl.absoluteString.hasSuffix("/")
                ? String(baseUrl.absoluteString.dropLast())
                : baseUrl.absoluteString
        }
        if let baseImageUrl {
            let url = baseImageUrl.absoluteString.hasSuffix("/")
                ? String(baseImageUrl.absoluteString.dropLast())
                : baseImageUrl.absoluteString
            imageServer = url
            widgetServer = url
        }
    }

    public static func apply(_ settings: AniSettings) {
        self.server = settings.server
        self.imageServer = settings.images
        self.widgetServer = settings.widget
    }
}
