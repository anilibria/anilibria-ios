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
    let method: NetworkManager.Method = .POST
    let body: (any Encodable)?

    init(filter: SeriesFilter, page: Int) {
        self.body = CatalogRequestData(page: page, filter: filter)
    }
}

private struct CatalogRequestData: Encodable {
    let page: Int
    let limit: Int = 25
    let filter: SeriesFilter

    enum CodingKeys: String, CodingKey {
        case page
        case limit
        case filter = "f"
    }

    init(page: Int, filter: SeriesFilter) {
        self.page = page
        self.filter = filter
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
}

public struct YearsRange: Encodable, Hashable {
    var fromYear: Int
    var toYear: Int

    enum CodingKeys: String, CodingKey {
        case fromYear = "from_year"
        case toYear = "to_year"
    }
}
