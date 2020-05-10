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
    var comments: VKComments?
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
        try decoder.apply { values in
            id <- values["id"]
            code <- values["code"]
            names <- values["names"] <- decorator
            count <- values["series"]
            poster <- values["poster"] <- urlConverter
            lastRelease <- values["last"] <- StringDateConverter()
            originalDate <- values["last"]
            moon <- values["moon"] <- urlConverter
            announce <- values["announce"] <- charactersConverter
            status <- values["status"]
            statusCode <- values["statusCode"]
            type <- values["type"] <- charactersConverter
            genres <- values["genres"]
            voices <- values["voices"]
            year <- values["year"]
            season <- values["season"]
            day <- values["day"]
            playlist <- values["playlist"]
            favorite <- values["favorite"]
            desc <- values["description"] <- AttributedConverter(css: Css.text())
            originalDesc <- values["description"]
            torrents <- values["torrents"]
        }
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
