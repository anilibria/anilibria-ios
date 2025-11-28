import Foundation

public enum VideoQuality: Int, CaseIterable, Codable {
    case fullHd
    case hd
    case sd

    func next() -> VideoQuality? {
        switch self {
        case .fullHd:
            return .hd
        case .hd:
            return .sd
        default:
            return nil
        }
    }

    var name: String {
        switch self {
        case .fullHd:
            return L10n.Common.Quality.fullHd
        case .hd:
            return L10n.Common.Quality.hd
        case .sd:
            return L10n.Common.Quality.sd
        }
    }
}

public struct PlaylistItem: Codable, Hashable {
    let id: String
    let title: String?
    let preview: URL?
    let ordinal: Double?
    let video: [VideoQuality: URL]
    let openingRange: Range<Int>?
    let endingRange: Range<Int>?
    let duration: TimeInterval

    var fullName: String {
        let items: [String?] = [
            ordinal.map { "\(NSNumber(value: $0))" },
            title
        ]
        return items.compactMap({ $0 }).joined(separator: ". ")
    }

    public func supportedQualities() -> [VideoQuality] {
        return self.video.keys.sorted(by: { $0.rawValue < $1.rawValue })
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameEnglish = "name_english"
        case ordinal
        case duration

        case preview
        case src

        case opening
        case ending
        case start
        case stop

        case hls1080 = "hls_1080"
        case hls720 = "hls_720"
        case hls480 = "hls_480"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urlConverter = URLConverter()
        self.id = try container.decode(required: .id)
        self.title = container.decode(.name) ?? container.decode(.nameEnglish)
        self.ordinal = container.decode(.ordinal)

        let openingStart: Int? = container.decode(.opening, .start)
        let openingStop: Int? = container.decode(.opening, .stop)
        let endingStart: Int? = container.decode(.ending, .start)
        let endingStop: Int? = container.decode(.ending, .stop)

        self.openingRange = if let openingStart, let openingStop, openingStart <= openingStop {
            .init(uncheckedBounds: (openingStart, openingStop))
        } else { nil }

        self.endingRange = if let endingStart, let endingStop, endingStart <= endingStop  {
            .init(uncheckedBounds: (endingStart, endingStop))
        } else { nil }

		var result: [VideoQuality: URL] = [:]
        if let url: URL = container.decode(.hls1080) {
			result[.fullHd] = url
		}
        if let url: URL = container.decode(.hls720) {
			result[.hd] = url
		}
        if let url: URL = container.decode(.hls480) {
			result[.sd] = url
		}
		self.video = result
        self.duration = container.decode(.duration) ?? 0
        self.preview = urlConverter.convert(from: container.decode(.preview, .src))
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeys.self) { container in
            container[.id] = id
            container[.name] = title
            container[.ordinal] = ordinal
            container[.duration] = duration

            container[.opening][.start] = openingRange?.lowerBound
            container[.opening][.ending] = openingRange?.upperBound
            container[.ending][.start] = endingRange?.lowerBound
            container[.ending][.ending] = endingRange?.upperBound

            container[.hls1080] = video[.fullHd]?.absoluteString
            container[.hls720] = video[.hd]?.absoluteString
            container[.hls480] = video[.sd]?.absoluteString

            container[.preview][.src] = preview?.absoluteString
        }
    }
}
