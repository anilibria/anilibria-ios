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

struct Skips: Decodable {
    let opening: Range<Int>?
    let ending: Range<Int>?
    
    public init(from decoder: Decoder) throws {
        let rangeConverter = RangeConverter()
        let opening: Range<Int>? = decoder["opening"] <- rangeConverter
        let ending: Range<Int>? = decoder["ending"] <- rangeConverter
        
        self.opening = opening
        self.ending = ending
    }
}

public final class PlaylistItem: NSObject, Decodable {
    var id: Int = 0
    var title: String = ""
    var video: [VideoQuality: URL] = [:]
    var skips: Skips?

    public func supportedQualities() -> [VideoQuality] {
        return self.video.keys.sorted(by: { $0.rawValue < $1.rawValue })
    }

    public init(from decoder: Decoder) throws {
        super.init()
        let urlConverter = URLConverter(Configuration.server)
		self.id <- decoder["id"]
		self.title <- decoder["title"]

		var result: [VideoQuality: URL] = [:]
		if let url: URL = decoder["fullhd"] <- urlConverter {
			result[.fullHd] = url
		}
		if let url: URL = decoder["hd"] <- urlConverter {
			result[.hd] = url
		}
		if let url: URL = decoder["sd"] <- urlConverter {
			result[.sd] = url
		}
		self.video = result
        self.skips <- decoder["skips"]
    }
}
