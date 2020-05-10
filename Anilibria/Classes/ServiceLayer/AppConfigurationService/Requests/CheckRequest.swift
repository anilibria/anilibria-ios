public struct CheckRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init() {
        self.parameters = [
            "query": "empty"
        ]
    }
}
