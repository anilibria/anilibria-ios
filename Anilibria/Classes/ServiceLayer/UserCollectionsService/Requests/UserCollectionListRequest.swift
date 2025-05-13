//
//  UserCollectionListRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct UserCollectionListRequest: BackendAPIRequest {
    typealias ResponseObject = PageData<Series>

    let endpoint: String = "/accounts/users/me/collections/releases"
    let method: NetworkManager.Method = .GET
    let parameters: [String: Any]

    init(type: UserCollectionType, data: SeriesSearchData, page: Int, limit: Int) {
        var results = data.parameters
        results["type_of_collection"] = type.rawValue
        results["page"] = page
        results["limit"] = limit

        self.parameters = results
    }
}
