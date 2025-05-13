//
//  GetUserCollectionDataRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct GetUserCollectionDataRequest: BackendAPIRequest {
    typealias ResponseObject = [UserCollectionData]

    let endpoint: String = "/accounts/users/me/collections/ids"
    let method: NetworkManager.Method = .GET
}
