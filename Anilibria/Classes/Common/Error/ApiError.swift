public final class ApiError: Decodable, Error, CustomStringConvertible {
    var code: Int = 0
    let message: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        self.message = container.decode("message") ?? "unknown"
    }

    public var description: String {
        return self.message
    }
}
