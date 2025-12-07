public struct RandomSeriesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Series]

    var requestData: RequestData = .init(
        endpoint: "/anime/releases/random"
    )

    init(limit: Int) {
        requestData.parameters = [
            "limit": limit
        ]
    }
}
