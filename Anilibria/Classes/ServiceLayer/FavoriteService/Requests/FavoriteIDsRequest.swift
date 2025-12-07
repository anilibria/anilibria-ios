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

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/favorites/ids"
    )
}
