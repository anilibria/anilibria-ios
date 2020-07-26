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
		self.id <- decoder["id"]
		self.title <- decoder["title"] <- SpecialCharactersConverter()
		self.image <- decoder["image"] <- URLConverter(Configuration.imageServer)
		self.vidUrl <- decoder["vid"] <- YouTubeConverter()
		self.views <- decoder["views"]
		self.comments <- decoder["comments"]
		self.date <- decoder["timestamp"] <- DateConverter()
    }
}
