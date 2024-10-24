import Foundation

struct AniConfig: Codable {
    let addresses: [AniAddress]
}

struct AniAddress: Codable {
    let name: String?
    let base: String
    let baseImages: String
    let widgetsSite: String
    let proxies: [AniProxy]
}

struct AniProxy: Codable {
    let tag: String?
    let name: String?
    let desc: String?
    let ip: String
    let port: Int
    let user: String?
    let password: String?

    func config() -> [AnyHashable: Any] {
        var proxyConfiguration = [String: Any]()
        proxyConfiguration.updateValue(1, forKey: "HTTPEnable")
        proxyConfiguration.updateValue(ip, forKey: "HTTPProxy")
        proxyConfiguration.updateValue(port, forKey: "HTTPPort")
        proxyConfiguration.updateValue(1, forKey: "HTTPSEnable")
        proxyConfiguration.updateValue(ip, forKey: "HTTPSProxy")
        proxyConfiguration.updateValue(port, forKey: "HTTPSPort")
        return proxyConfiguration
    }
}

final class AniSettings: Codable {
    let server: String
    let images: String
    let proxy: AniProxy?
    var next: AniSettings?

    init(address: AniAddress, proxy: AniProxy?) {
        self.server = address.base
        self.images = address.baseImages
        self.proxy = proxy
    }

    static func create(from config: AniConfig) -> AniSettings? {
        var result: AniSettings?
        var current: AniSettings?
        for address in config.addresses {
            let settings = AniSettings(address: address, proxy: nil)
            current?.next = settings
            if current == nil {
                result = settings
            }
            current = settings
        }

        for address in config.addresses {
            for proxy in address.proxies {
                let settings = AniSettings(address: address, proxy: proxy)
                current?.next = settings
                current = settings
            }
        }

        return result
    }

    private init(server: String, images: String) {
        self.server = server
        self.images = images
        self.proxy = nil
        self.next = nil
    }

    static let `default`: AniSettings = AniSettings(server: "https://anilibria.top",
                                                    images: "https://anilibria.top")
}
