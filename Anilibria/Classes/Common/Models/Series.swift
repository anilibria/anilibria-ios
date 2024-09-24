import Foundation

public enum StatusCode: String, Codable {
    case progress = "1"
    case finished = "2"
    case hidden = "3"
    case notOngoing = "4"
}

public final class Series: NSObject, Codable {
    var id: Int = 0
    var code: String = ""
    var names: [String] = []
    var count: String = ""
    var poster: URL?
    var lastRelease: Date?
    var moon: URL?
    var announce: String = ""
    var status: String = ""
    var statusCode: StatusCode?
    var type: String = ""
    var genres: [String] = []
    var voices: [String] = []
    var year: String = ""
    var season: String = ""
    var day: WeekDay?
    var desc: NSAttributedString?
    var playlist: [PlaylistItem] = []
    var favorite: Favorite?
    var torrents: [Torrent] = []

    private var originalDesc: String = ""
    private var originalDate: String = ""

    func hasUpdates() -> Bool {
        guard let releaseTime = self.lastRelease else {
            return false
        }
        let twoDaysAgo = Date() - 2.days
        return releaseTime >= twoDaysAgo
    }

    public init(from decoder: Decoder) throws {
        super.init()
        let urlConverter = URLConverter(Configuration.imageServer)
        let charactersConverter = SpecialCharactersConverter()
        let decorator = ArrayConverterDecorator(charactersConverter)
		self.id <- decoder["id"]
		self.code <- decoder["code"]
		self.names <- decoder["names"] <- decorator
		self.count <- decoder["series"]
		self.poster <- decoder["poster"] <- urlConverter
		self.lastRelease <- decoder["last"] <- StringDateConverter()
		self.originalDate <- decoder["last"]
		self.moon <- decoder["moon"] <- urlConverter
		self.announce <- decoder["announce"] <- charactersConverter
		self.status <- decoder["status"]
		self.statusCode <- decoder["statusCode"]
		self.type <- decoder["type"] <- charactersConverter
		self.genres <- decoder["genres"]
		self.voices <- decoder["voices"]
		self.year <- decoder["year"]
		self.season <- decoder["season"]
		self.day <- decoder["day"]
		self.playlist <- decoder["playlist"]
		self.favorite <- decoder["favorite"]
		self.desc <- decoder["description"] <- AttributedConverter(css: Css.text())
		self.originalDesc <- decoder["description"]
		self.torrents <- decoder["torrents"]
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply { values in
            values["id"] = id
            values["code"] = code
            values["names"] = names
            values["series"] = count
            values["poster"] = poster
            values["last"] = originalDate
            values["moon"] = moon
            values["announce"] = announce
            values["statusCode"] = statusCode
            values["genres"] = genres
            values["voices"] = voices
            values["season"] = season
            values["day"] = day
            values["description"] = originalDesc
        }
    }
}
