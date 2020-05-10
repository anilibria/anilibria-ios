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
    static let minSize: CGSize = CGSize(width: 480, height: 800)
    static let maxSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                        height: CGFloat.greatestFiniteMagnitude)
    
    static func adapt(_ width: CGFloat) -> CGFloat {
        return width > maxWidth ? maxWidth : width
    }
}

struct Keys {
    static let yandexMetricaApiKey = "48d49aa0-6aad-407e-a738-717a6c77d603"
}

struct VKCookie {
    static let name = "remixsid"
}

struct Css {
    static func text(_ size: Double = 15, color: UIColor? = nil) -> String {
        var cssColor = ""
        if let hex = color?.toHexString() {
            cssColor = "color: \(hex) !important;"
        }
        
        return "<style type=\"text/css\"> * { font-size: \(size)px; font-family: -apple-system; \(cssColor)} </style>"
    }
}

struct URLS {
    static let team: URL? = URL(string: "https://www.anilibria.tv/pages/team.php")
    static let donate: URL? = URL(string: "https://www.anilibria.tv/pages/donate.php")
    
    static let rightholders: URL? = URL(string: "https://www.anilibria.tv/pages/rightholders.php")
    static let vk: URL? = URL(string: "https://vk.com/anilibria")
    static let youtube: URL? = URL(string: "https://youtube.com/channel/UCuF8ghQWaa7K-28llm-K3Zg")
    static let patreon: URL? = URL(string: "https://patreon.com/anilibria")
    static let telegram: URL? = URL(string: "https://t.me/anilibria_tv")
    static let discord: URL? = URL(string: "https://discordapp.com/invite/anilibria")
    static let anilibria: URL? = URL(string: "https://www.anilibria.tv")
    
    static let register: URL? = URL(string: "https://www.anilibria.tv/pages/login.php")
    
    static let config: URL! = URL(string: "https://raw.githubusercontent.com/anilibria/anilibria-app/master/config.json")
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
            return URL(string: "https://www.anilibria.tv/release/\(value.code).html")
        }
        return nil
    }
}
