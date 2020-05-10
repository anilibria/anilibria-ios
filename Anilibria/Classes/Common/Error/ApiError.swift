public final class ApiError: Decodable, Error, CustomStringConvertible {
    var code: Int = 0
    let message: String

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: String.self)
        self.message = values["message", default: "unknown"]
    }

    public var description: String {
        return self.message
    }
}
