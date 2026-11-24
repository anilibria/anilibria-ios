public struct SeriesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Series

    var requestData: RequestData

    init(alias: String) {
        requestData = .init(endpoint: "/anime/releases/\(alias)")
    }

    init(id: Int) {
        requestData = .init(endpoint: "/anime/releases/\(id)")
    }
}
