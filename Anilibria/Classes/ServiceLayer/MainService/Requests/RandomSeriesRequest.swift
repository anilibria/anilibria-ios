public struct RandomSeriesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Series]

    let endpoint: String = "/anime/releases/random"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]
    var headers: [String : String] = [:]

    init(limit: Int) {
        self.parameters = [
            "limit": limit
        ]
    }
}
