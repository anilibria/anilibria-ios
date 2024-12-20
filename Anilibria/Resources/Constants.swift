import UIKit

public typealias ActionFunc = () -> Void
public typealias Action<T> = (T) -> Void
public typealias ActionIO<I, O> = (I) -> (O)
public typealias Factory<O> = () -> (O)

struct Constants {
    static let downloadFolder: String = "Anilibria Files"
}

struct Sizes {
    static let maxWidth: CGFloat = 500
    static let minSize: CGSize = CGSize(width: 1000, height: 800)
    static let maxSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                        height: CGFloat.greatestFiniteMagnitude)
    
    static func adapt(_ width: CGFloat) -> CGFloat {
        return width > maxWidth ? maxWidth : width
    }
}

struct Keys {
    static let yandexMetricaApiKey = "48d49aa0-6aad-407e-a738-717a6c77d603"
}

struct URLS {
    static let donate: URL? = URL(string: "https://anilibria.top/support")

    static let vk: URL? = URL(string: "https://vk.com/anilibria")
    static let youtube: URL? = URL(string: "https://www.youtube.com/user/anilibriatv")
    static let patreon: URL? = URL(string: "https://www.patreon.com/anilibria")
    static let telegram: URL? = URL(string: "https://t.me/anilibria")
    static let discord: URL? = URL(string: "https://discord.gg/M6yCGeGN9B")
    static let boosty: URL? = URL(string: "https://boosty.to/anilibriatv")

    static let signUp: URL? = URL(string: "https://anilibria.top/app/auth/registration/new")

    static let config = "https://raw.githubusercontent.com/anilibria/anilibria-app/master/config.json"
}

struct Css {
    static func text(_ size: Double = 15) -> String {
        return "<style type=\"text/css\"> * { font-size: \(size)px; font-family: -apple-system; } </style>"
    }
}

struct URLHelper {
    static func isRelease(url: URL?) -> String? {
        guard let url = url else {
            return nil
        }
        let components = url.pathComponents
        let count = components.count
        if  count > 1 && components[count - 2] == "release" {
            var code = url.lastPathComponent
            if code.hasSuffix(".html") {
                code.removeLast(5)
            }
            return code
        }
        return nil
    }

    
    static func searchUrl(text: String) -> URL? {
        let query = text.split(separator: " ")
            .compactMap {
                $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            }
            .joined(separator: "+")
        return URL(string: "https://www.google.ru/search?q=\(query)")
    }
    
    static func releaseUrl(_ series: Series?) -> URL? {
        if let value = series {
            return URL(string: "https://anilibria.top/anime/releases/release/\(value.alias)/episodes")
        }
        return nil
    }
}

struct Regexp {
    static let email = #"[A-z0-9._%+-]+@[A-z0-9.-]+\.[A-z0-9]{2,6}"#
}
