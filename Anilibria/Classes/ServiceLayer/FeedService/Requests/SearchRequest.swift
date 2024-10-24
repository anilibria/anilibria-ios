public struct SearchRequest: BackendAPIRequest {
    typealias ResponseObject = [Series]

    let endpoint: String = "/app/search/releases"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]

    init(query: String) {
        self.parameters = [
            "query": query
        ]
    }
}
