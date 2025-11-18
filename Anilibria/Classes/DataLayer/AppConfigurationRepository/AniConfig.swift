import Foundation

struct AniConfig: Codable, Hashable {
    let addresses: [AniAddress]
}

struct AniAddress: Codable, Hashable {
    let baseUrl: URL
    let baseImagesUrl: URL
}

extension AniConfig {
    static var `default`: AniConfig = {
        let url = URL(string: "https://www.anilibria.top")!
        return AniConfig(addresses: [
            AniAddress(
                baseUrl: url,
                baseImagesUrl: url
            )
        ])
    }()
}

struct AniConfigInfo: Codable {
    struct Item: Codable, Hashable {
        var address: AniAddress
        var priority: Int
    }

    private(set) var config: AniConfig?
    private(set) var updatedAt: Date?

    var items: Set<Item> = []

    mutating func update(with new: AniConfig) {
        if config != new {
            set(config: new)
        }
        updatedAt = Date()
    }

    private mutating func set(config: AniConfig) {
        self.config = config
        var count = config.addresses.count
        self.items = Set(config.addresses.map {
            defer { count -= 1 }
            return Item(address: $0, priority: count)
        })
    }

    var isOutdated: Bool {
        guard let updatedAt else { return true }
        return Date().timeIntervalSince(updatedAt) > Self.cacheDuration
    }

    func topPriorityItem() -> Item? {
        items.sorted(by: { $0.priority > $1.priority }).first
    }
}

extension AniConfigInfo {
    static let cacheDuration: TimeInterval = 60 * 60
}
