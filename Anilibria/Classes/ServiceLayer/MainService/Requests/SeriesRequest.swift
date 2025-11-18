public struct SeriesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Series

    let endpoint: String
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]

    init(alias: String) {
        endpoint = "/anime/releases/\(alias)"
    }

    init(id: Int) {
        endpoint = "/anime/releases/\(id)"
    }
}
