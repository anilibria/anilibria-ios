public struct FeedRequest: BackendAPIRequest {
    typealias ResponseObject = [Feed]

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(page: Int) {
        self.parameters = [
            "query": "feed",
            "filter": "id,code,poster,names,last,series,description",
            "page": page,
            "perPage": 25
        ]
    }
}
