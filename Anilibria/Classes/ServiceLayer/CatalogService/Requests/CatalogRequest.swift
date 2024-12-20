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

    init(filter: SeriesFilter, page: Int, limit: Int) {
        var results = filter.parameters
        results["page"] = page
        results["limit"] = limit

        self.parameters = results
    }
}

public enum SeriesSorting: String {
    case mostPopularity = "1"
    case newest = "2"
}

public struct SeriesFilter: Hashable {
    var genres: Set<Int> = []
    var types: Set<String> = []
    var seasons: Set<String> = []
    var yearsRange: YearsRange?
    var years:  Set<Int> = []
    var sorting: String?
    var ageRatings: Set<String> = []
    var publishStatuses: Set<String> = []
    var productionStatuses: Set<String> = []
    var search: String?

    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        if let sorting {
            result["f[sorting]"] = sorting
        }
        if let yearsRange {
            result["f[years][from_year]"] = yearsRange.fromYear
            result["f[years][to_year]"] = yearsRange.toYear
        }
        if !years.isEmpty {
            result["f[years]"] = years.lazy.map { "\($0)" }.joined(separator: ",")
        }
        if !genres.isEmpty {
            result["f[genres]"] = genres.lazy.map { "\($0)" }.joined(separator: ",")
        }
        if !types.isEmpty {
            result["f[types]"] = types.joined(separator: ",")
        }
        if !seasons.isEmpty {
            result["f[seasons]"] = seasons.joined(separator: ",")
        }
        if !ageRatings.isEmpty {
            result["f[age_ratings]"] = ageRatings.joined(separator: ",")
        }
        if !publishStatuses.isEmpty {
            result["f[publish_statuses]"] = publishStatuses.joined(separator: ",")
        }
        if !productionStatuses.isEmpty {
            result["f[production_statuses]"] = productionStatuses.joined(separator: ",")
        }
        if let search, !search.isEmpty {
            result["f[search]"] = search
        }
        return result
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
