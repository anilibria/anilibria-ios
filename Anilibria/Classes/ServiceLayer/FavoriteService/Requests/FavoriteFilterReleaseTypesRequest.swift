//
//  FavoriteFilterReleaseTypesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FavoriteFilterReleaseTypesRequest: BackendAPIRequest {
    typealias ResponseObject = [DescribedValue<String>]

    let endpoint: String = "/accounts/users/me/favorites/references/types"
    let method: NetworkManager.Method = .GET
}
