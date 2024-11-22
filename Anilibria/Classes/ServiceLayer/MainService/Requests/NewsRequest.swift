public struct NewsRequest: BackendAPIRequest {
    typealias ResponseObject = [News]

    let endpoint: String = "/media/videos"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]

    init(limit: Int) {
        self.parameters = [
            "limit": limit
        ]
    }
}
