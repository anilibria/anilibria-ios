//
//  CatalogRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

public struct CatalogRequest: BackendAPIRequest {
    typealias ResponseObject = PageData<Series>

    let endpoint: String = "/anime/catalog/releases"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]

    init(data: SeriesSearchData, page: Int, limit: Int) {
        var results = data.parameters
        results["page"] = page
        results["limit"] = limit

        self.parameters = results
    }
}

public enum SeriesSorting: String {
    case mostPopularity = "1"
    case newest = "2"
}

public struct SeriesSearchData: Hashable {
    var search: String = ""
    var filter: Filter = .init()

    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        if let sorting = filter.sorting {
            result["f[sorting]"] = sorting
        }
        if let yearsRange = filter.yearsRange {
            result["f[years][from_year]"] = yearsRange.fromYear
            result["f[years][to_year]"] = yearsRange.toYear
        }
        if !filter.years.isEmpty {
            result["f[years]"] = filter.years.lazy.map { "\($0)" }.joined(separator: ",")
        }
        if !filter.genres.isEmpty {
            result["f[genres]"] = filter.genres.lazy.map { "\($0)" }.joined(separator: ",")
        }
        if !filter.types.isEmpty {
            result["f[types]"] = filter.types.joined(separator: ",")
        }
        if !filter.seasons.isEmpty {
            result["f[seasons]"] = filter.seasons.joined(separator: ",")
        }
        if !filter.ageRatings.isEmpty {
            result["f[age_ratings]"] = filter.ageRatings.joined(separator: ",")
        }
        if !filter.publishStatuses.isEmpty {
            result["f[publish_statuses]"] = filter.publishStatuses.joined(separator: ",")
        }
        if !filter.productionStatuses.isEmpty {
            result["f[production_statuses]"] = filter.productionStatuses.joined(separator: ",")
        }
        if !search.isEmpty {
            result["f[search]"] = search
        }
        return result
    }
}

public extension SeriesSearchData {
    struct Filter: Hashable {
        var genres: Set<Int> = []
        var types: Set<String> = []
        var seasons: Set<String> = []
        var yearsRange: YearsRange?
        var years:  Set<Int> = []
        var sorting: String?
        var ageRatings: Set<String> = []
        var publishStatuses: Set<String> = []
        var productionStatuses: Set<String> = []

        var isEmpty: Bool {
            self == Filter()
        }
    }
}

public struct YearsRange: Encodable, Hashable {
    var fromYear: Int
    var toYear: Int

    enum CodingKeys: String, CodingKey {
        case fromYear = "from_year"
        case toYear = "to_year"
    }
}
