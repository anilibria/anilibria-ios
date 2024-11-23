public struct RandomSeriesRequest: BackendAPIRequest {
    typealias ResponseObject = [Series]

    let endpoint: String = "/anime/releases/random"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]

    init(limit: Int) {
        self.parameters = [
            "limit": limit
        ]
    }
}
