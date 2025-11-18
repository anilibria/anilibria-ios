public struct NewsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [News]

    let endpoint: String = "/media/videos"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]
    var headers: [String : String] = [:]

    init(limit: Int) {
        self.parameters = [
            "limit": limit
        ]
    }
}
