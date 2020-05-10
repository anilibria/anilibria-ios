public struct NewsRequest: BackendAPIRequest {
    typealias ResponseObject = PageData<News>

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(page: Int) {
        self.parameters = [
            "query": "youtube",
            "page": page,
            "perPage": 25
        ]
    }
}
