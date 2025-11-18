//
//  FavoriteFilterYearsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FavoriteFilterYearsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Int]

    let endpoint: String = "/accounts/users/me/favorites/references/years"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
