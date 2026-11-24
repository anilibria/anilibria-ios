//
//  ChangeFavoriteRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 21.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ChangeFavoriteRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData

    init(add: Bool, id: Int) {
        requestData = .init(
            endpoint: "/accounts/users/me/favorites",
            method: add ? .POST : .DELETE,
            body: [FavoriteItem(releaseID: id)]
        )
    }
}

private struct FavoriteItem: Encodable {
    let releaseID: Int

    enum CodingKeys: String, CodingKey {
        case releaseID = "release_id"
    }
}
