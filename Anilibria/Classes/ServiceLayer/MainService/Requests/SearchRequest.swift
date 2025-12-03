public struct SearchRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Series]

    let endpoint: String = "/app/search/releases"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]
    var headers: [String : String] = [:]

    init(query: String) {
        self.parameters = [
            "query": query
        ]
    }
}
