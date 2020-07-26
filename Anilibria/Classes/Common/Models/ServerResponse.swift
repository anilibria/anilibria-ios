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
        self.key <- decoder["key"]
		self.message <- decoder["mes"]
		self.error <- decoder["err"] <- ErrorConverter()
    }
}
