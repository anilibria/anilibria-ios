public struct RemoveFavoriteRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(id: Int) {
        self.parameters = [
            "query": "favorites",
            "id": "\(id)",
            "action": "delete"
        ]
    }
}
