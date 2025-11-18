//
//  FavoriteFilterSortingRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FavoriteFilterSortingRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Sorting]

    let endpoint: String = "/accounts/users/me/favorites/references/sorting"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
