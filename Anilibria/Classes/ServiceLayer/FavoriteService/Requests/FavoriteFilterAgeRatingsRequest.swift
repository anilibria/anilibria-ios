//
//  FavoriteFilterAgeRatingsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FavoriteFilterAgeRatingsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [AgeRating]

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/favorites/references/age-ratings"
    )
}
