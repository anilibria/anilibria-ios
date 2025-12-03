public struct FavoriteListRequest: AuthorizableAPIRequest {
    typealias ResponseObject = PageData<Series>

    let endpoint: String = "/accounts/users/me/favorites/releases"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]
    var headers: [String : String] = [:]

    init(data: SeriesSearchData, page: Int, limit: Int) {
        var results = data.parameters
        results["page"] = page
        results["limit"] = limit

        self.parameters = results
    }
}
