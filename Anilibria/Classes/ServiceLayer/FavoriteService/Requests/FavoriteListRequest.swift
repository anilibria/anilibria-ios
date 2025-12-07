public struct FavoriteListRequest: AuthorizableAPIRequest {
    typealias ResponseObject = PageData<Series>

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/favorites/releases"    )

    init(data: SeriesSearchData, page: Int, limit: Int) {
        var results = data.parameters
        results["page"] = page
        results["limit"] = limit

        requestData.parameters = results
    }
}
