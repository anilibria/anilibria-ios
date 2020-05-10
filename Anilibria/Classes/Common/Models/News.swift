import Foundation

public final class News: NSObject, Decodable {
    var id: Int = 0
    var title: String = ""
    var image: URL?
    var vidUrl: URL?
    var views: Int = 0
    var comments: Int = 0
    var date: Date?

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            id <- values["id"]
            title <- (values["title"] <- SpecialCharactersConverter())
            image <- values["image"] <- URLConverter(Configuration.imageServer)
            vidUrl <- values["vid"] <- YouTubeConverter()
            views <- values["views"]
            comments <- values["comments"]
            date <- values["timestamp"] <- DateConverter()
        }
    }
}
