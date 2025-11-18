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

    let endpoint: String = "/accounts/users/me/favorites"
    let method: NetworkManager.Method
    let body: (any Encodable)?
    var headers: [String : String] = [:]

    init(add: Bool, id: Int) {
        self.method = add ? .POST : .DELETE
        self.body = [FavoriteItem(releaseID: id)]
    }
}

private struct FavoriteItem: Encodable {
    let releaseID: Int

    enum CodingKeys: String, CodingKey {
        case releaseID = "release_id"
    }
}
