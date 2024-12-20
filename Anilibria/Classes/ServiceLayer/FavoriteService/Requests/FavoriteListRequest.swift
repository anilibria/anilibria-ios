public struct FavoriteListRequest: BackendAPIRequest {
    typealias ResponseObject = PageData<Series>

    let endpoint: String = "/accounts/users/me/favorites/releases"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]

    init(filter: SeriesFilter, page: Int, limit: Int) {
        var results = filter.parameters
        results["page"] = page
        results["limit"] = limit

        self.parameters = results
    }
}
