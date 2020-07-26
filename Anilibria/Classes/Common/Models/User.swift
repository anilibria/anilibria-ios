import Foundation

public struct User: Codable {
    private(set) var id: Int = 0
    private(set) var name: String = ""
    private(set) var avatar: URL?

    public init(from decoder: Decoder) throws {
		self.id <- decoder["id"]
		self.name <- decoder["login"]
		self.avatar <- decoder["avatar"] <- URLConverter(Configuration.imageServer)
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply { values in
            values["id"] = id
            values["login"] = name
            values["avatar"] = avatar?.absoluteString
        }
    }
}
