public struct CatalogRequest: BackendAPIRequest {
    typealias ResponseObject = PageData<Series>

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(filter: SeriesFilter, page: Int) {
        self.parameters = [
            "query": "catalog",
            "filter": "id,code,poster,names,last,series,description",
            "search": filter.jsonString ?? "",
            "sort": filter.sorting.rawValue,
            "finish": filter.isCompleted ? "2" : "1",
            "xpage": "catalog",
            "page": page,
            "perPage": 25
        ]
    }
}

public enum SeriesSorting: String {
    case mostPopularity = "1"
    case newest = "2"
}

public struct SeriesFilter: Encodable, Equatable {
    var genres: Set<String> = []
    var years: Set<String> = []
    var seasons: Set<String> = []
    var sorting: SeriesSorting = .mostPopularity
    var isCompleted: Bool = false

    public func encode(to encoder: Encoder) throws {
        encoder.apply { values in
            values["genre"] = genres.joined(separator: ",")
            values["year"] = years.joined(separator: ",")
            values["season"] = seasons.joined(separator: ",")
        }
    }
}
