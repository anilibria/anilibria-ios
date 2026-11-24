//
//  FavoriteFilterGenresRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FavoriteFilterGenresRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Genre]

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/favorites/references/genres"
    )
}
