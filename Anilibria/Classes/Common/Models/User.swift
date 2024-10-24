import Foundation

public struct User: Codable, Hashable {
    let id: Int
    let name: String
    let avatar: URL?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        self.id = try container.decode(required: "id")
		self.name = container.decode("nickname") ?? ""
        self.avatar = URLConverter(Configuration.imageServer).convert(
            from: container.decode("avatar", "preview")
        )
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeyString.self) { values in
            values["id"] = id
            values["nickname"] = name
            values["avatar"]["preview"] = avatar?.absoluteString
        }
    }
}
