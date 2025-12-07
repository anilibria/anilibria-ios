//
//  ChangeUserCollectionRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct ChangeUserCollectionRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/collections"
    )

    init(id: Int, type: UserCollectionType?) {
        if let type {
            requestData.method = .POST
            requestData.body = [UserCollectionData(seriesID: id, collectionType: type)]

        } else {
            requestData.method = .DELETE
            requestData.body = [["release_id": id]]
        }
    }
}
