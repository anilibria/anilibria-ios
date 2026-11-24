public struct SearchRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Series]

    var requestData: RequestData = .init(
        endpoint: "/app/search/releases"
    )

    init(query: String) {
        requestData.parameters = [
            "query": query
        ]
    }
}
