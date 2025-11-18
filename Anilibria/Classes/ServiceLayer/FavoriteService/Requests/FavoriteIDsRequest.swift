//
//  FavoriteIDsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 21.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FavoriteIDsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Int]

    let endpoint: String = "/accounts/users/me/favorites/ids"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
