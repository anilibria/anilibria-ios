//
//  ChangeUserCollectionRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct ChangeUserCollectionRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    let endpoint: String = "/accounts/users/me/collections"
    let method: NetworkManager.Method
    let body: (any Encodable)?

    init(id: Int, type: UserCollectionType?) {
        if let type {
            method = .POST
            body = [UserCollectionData(seriesID: id, collectionType: type)]

        } else {
            method = .DELETE
            body = [["release_id": id]]
        }
    }
}
