public struct FavoriteListRequest: BackendAPIRequest {
    typealias ResponseObject = PageData<Series>

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init() {
        self.parameters = [
            "query": "favorites",
            "filter": "id,code,poster,names,last,series,description"
        ]
    }
}
