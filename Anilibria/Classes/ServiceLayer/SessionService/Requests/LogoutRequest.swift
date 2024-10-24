public struct LogoutRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    private(set) var endpoint: String = "/public/logout.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any] = [:]

    init() {}
}
