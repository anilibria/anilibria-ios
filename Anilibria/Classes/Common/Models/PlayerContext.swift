import Foundation

public struct PlayerContext: Codable {
    var quality: VideoQuality
    var number: Int = 0
    var time: Double = 0
    var allItems: [Int: Double] = [:]

    enum CodingKeys: String, CodingKey {
        case quality
        case number
        case time
        case allItems
    }

    public init(quality: VideoQuality) {
        self.quality = quality
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quality = container.decode(.quality) ?? .fullHd
        number = container.decode(.number) ?? 0
        time = container.decode(.time) ?? 0
        allItems = container.decode(.allItems) ?? [:]
    }
}
