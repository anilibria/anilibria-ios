import Foundation
#if canImport(UIKit)
import UIKit
#endif

public typealias ActionFunc = () -> Void
public typealias Action<T> = (T) -> Void
public typealias ActionIO<I, O> = (I) -> (O)
public typealias Factory<O> = () -> (O)

public struct Constants {
    static let downloadFolder: String = "Anilibria Files"
}

#if canImport(UIKit)
public struct Sizes {
    public static let maxWidth: CGFloat = 500
    public static let minSize: CGSize = CGSize(width: 1000, height: 800)
    public static let maxSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                        height: CGFloat.greatestFiniteMagnitude)
    
    public static func adapt(_ width: CGFloat) -> CGFloat {
        return width > maxWidth ? maxWidth : width
    }
}
#endif

public struct VKCookie {
    public static let name = "remixsid"
}

#if canImport(UIKit)
public struct Css {
    static func text(_ size: Double = 15, color: UIColor? = nil) -> String {
        var cssColor = ""
        if let hex = color?.toHexString() {
            cssColor = "color: \(hex) !important;"
        }
        
        return "<style type=\"text/css\"> * { font-size: \(size)px; font-family: -apple-system; \(cssColor)} </style>"
    }
}
#else
public struct Css {
    static func text(_ size: Double = 15, color: Any? = nil) -> String {
        return "<style type=\"text/css\"> * { font-size: \(size)px; font-family: -apple-system; } </style>"
    }
}
#endif

public struct URLS {
    public static let team: URL? = URL(string: "https://www.anilibria.tv/pages/team.php")
    public static let donate: URL? = URL(string: "https://www.anilibria.tv/pages/donate.php")
    
    public static let rightholders: URL? = URL(string: "https://www.anilibria.tv/pages/rightholders.php")
    public static let vk: URL? = URL(string: "https://vk.com/anilibria")
    public static let youtube: URL? = URL(string: "https://youtube.com/channel/UCuF8ghQWaa7K-28llm-K3Zg")
    public static let patreon: URL? = URL(string: "https://patreon.com/anilibria")
    public static let telegram: URL? = URL(string: "https://t.me/anilibria_tv")
    public static let discord: URL? = URL(string: "https://discordapp.com/invite/anilibria")
    public static let anilibria: URL? = URL(string: "https://www.anilibria.tv")
    
    public static let register: URL? = URL(string: "https://www.anilibria.tv/pages/login.php")
    
    public static let config: URL! = URL(string: "https://raw.githubusercontent.com/anilibria/anilibria-app/master/config.json")
}

public struct URLHelper {
    public static func isRelease(url: URL?) -> String? {
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

    
    public static func searchUrl(text: String) -> URL? {
        let query = text.split(separator: " ")
            .compactMap {
                $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            }
            .joined(separator: "+")
        return URL(string: "https://www.google.ru/search?q=\(query)")
    }
    
    public static func releaseUrl(_ series: Series?) -> URL? {
        if let value = series {
            return URL(string: "https://www.anilibria.tv/release/\(value.code).html")
        }
        return nil
    }
}
