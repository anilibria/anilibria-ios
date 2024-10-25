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

    init(filter: SeriesFilter, page: Int) {
        var results = filter.parameters
        results["page"] = page
        results["limit"] = 25

        self.parameters = results
    }
}

public enum SeriesSorting: String {
    case mostPopularity = "1"
    case newest = "2"
}

public struct SeriesFilter: Encodable, Hashable {
    var genres: Set<Int> = []
    var types: Set<String> = []
    var seasons: Set<String> = []
    var years: YearsRange?
    var sorting: String?
    var ageRatings: Set<String> = []
    var publishStatuses: Set<String> = []
    var productionStatuses: Set<String> = []

    enum CodingKeys: String, CodingKey {
        case genres
        case types
        case seasons
        case years
        case sorting
        case ageRatings = "age_ratings"
        case publishStatuses = "publish_statuses"
        case productionStatuses = "production_statuses"
    }

    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        if let sorting {
            result["f[sorting]"] = sorting
        }
        if let years {
            result["f[years][from_year]"] = years.fromYear
            result["f[years][to_year]"] = years.toYear
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
