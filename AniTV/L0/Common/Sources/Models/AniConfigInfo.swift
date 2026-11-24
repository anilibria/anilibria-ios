import Foundation

// MARK: - API v2 config (from master)

public struct AniConfigV2: Codable, Hashable {
    public let addresses: [AniAddressV2]

    public init(addresses: [AniAddressV2]) {
        self.addresses = addresses
    }
}

public struct AniAddressV2: Codable, Hashable {
    public let baseUrl: URL
    public let baseImagesUrl: URL

    public init(baseUrl: URL, baseImagesUrl: URL) {
        self.baseUrl = baseUrl
        self.baseImagesUrl = baseImagesUrl
    }
}

public extension AniConfigV2 {
    static var `default`: AniConfigV2 = {
        let url = URL(string: "https://www.anilibria.top")!
        return AniConfigV2(addresses: [
            AniAddressV2(
                baseUrl: url,
                baseImagesUrl: url
            )
        ])
    }()
}

public struct AniConfigInfo: Codable {
    public struct Item: Codable, Hashable {
        public var address: AniAddressV2
        public var priority: Int

        public init(address: AniAddressV2, priority: Int) {
            self.address = address
            self.priority = priority
        }
    }

    public private(set) var config: AniConfigV2?
    public private(set) var updatedAt: Date?

    public var items: Set<Item> = []

    public init() {}

    public mutating func update(with new: AniConfigV2) {
        if config != new {
            set(config: new)
        }
        updatedAt = Date()
    }

    private mutating func set(config: AniConfigV2) {
        self.config = config
        var count = config.addresses.count
        self.items = Set(config.addresses.map {
            defer { count -= 1 }
            return Item(address: $0, priority: count)
        })
    }

    public var isOutdated: Bool {
        guard let updatedAt else { return true }
        return Date().timeIntervalSince(updatedAt) > Self.cacheDuration
    }

    public func topPriorityItem() -> Item? {
        items.sorted(by: { $0.priority > $1.priority }).first
    }
}

public extension AniConfigInfo {
    static let cacheDuration: TimeInterval = 60 * 60
}
