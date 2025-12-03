//
//  AgeRatingsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct AgeRatingsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [AgeRating]

    let endpoint: String = "/anime/catalog/references/age-ratings"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
