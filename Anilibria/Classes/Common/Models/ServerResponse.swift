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
        try decoder.apply { values in
            key <- values["key"]
            message <- values["mes"]
            error <- values["err"] <- ErrorConverter()
        }
    }
}
