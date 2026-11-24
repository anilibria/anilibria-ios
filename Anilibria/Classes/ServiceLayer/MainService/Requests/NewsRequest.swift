public struct NewsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [News]

    var requestData: RequestData = .init(
        endpoint: "/media/videos"
    )

    init(limit: Int) {
        requestData.parameters = [
            "limit": limit
        ]
    }
}
