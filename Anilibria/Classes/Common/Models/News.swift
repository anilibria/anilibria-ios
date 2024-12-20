import Foundation

public struct News: Hashable, Decodable {
    let id: Int
    let title: String
    let image: URL?
    let vidUrl: URL?
    let views: Int
    let comments: Int
    let date: Date?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let dateConverter = DateConverter()
        let urlConverter = URLConverter(Configuration.imageServer)
        self.id = try container.decode(required: "id")
        self.title = container.decode("title") ?? ""
        self.image = urlConverter.convert(from: container.decode("image", "preview"))
        self.vidUrl = container.decode("url")
        self.views = container.decode("views") ?? 0
        self.comments = container.decode("comments") ?? 0
        self.date = dateConverter.convert(from: container.decode("created_at"))
    }
}
