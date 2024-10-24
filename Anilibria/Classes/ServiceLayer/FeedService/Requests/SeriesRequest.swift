public struct SeriesRequest: BackendAPIRequest {
    typealias ResponseObject = Series

    let endpoint: String
    let method: NetworkManager.Method = .GET

    init(alias: String) {
        endpoint = "/anime/releases/\(alias)"
    }

    init(id: Int) {
        endpoint = "/anime/releases/\(id)"
    }
}
