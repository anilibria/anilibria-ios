public struct YearsRequest: BackendAPIRequest {
    typealias ResponseObject = [String]

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init() {
        self.parameters = [
            "query": "years"
        ]
    }
}
