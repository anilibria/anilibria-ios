public struct SeriesRequest: BackendAPIRequest {
    typealias ResponseObject = Series

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(code: String) {
        self.parameters = [
            "query": "release",
            "code": code
        ]
    }
}
