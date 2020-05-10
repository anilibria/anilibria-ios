public struct SearchRequest: BackendAPIRequest {
    typealias ResponseObject = [Series]

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(query: String) {
        self.parameters = [
            "query": "search",
            "filter": "id,code,poster,names,last,series",
            "search": query
        ]
    }
}
