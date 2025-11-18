//
//  CollectionsFilterAgeRatingsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct CollectionsFilterAgeRatingsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [AgeRating]

    let endpoint: String = "/accounts/users/me/collections/references/age-ratings"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
