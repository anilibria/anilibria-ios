import Foundation

enum ResponseKey: String, Decodable {
    case success
    case authorized
    case unknown
}

public struct ServerResponse: Decodable {
    private(set) var key: ResponseKey = .unknown
    private(set) var message: String = ""
    private(set) var error: AppError?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        self.key = container.decode("key") ?? .unknown
		self.message = container.decode("message") ?? ""
        let text: String? = container.decode("err")
        self.error = ErrorConverter().convert(from: text)
    }
}
