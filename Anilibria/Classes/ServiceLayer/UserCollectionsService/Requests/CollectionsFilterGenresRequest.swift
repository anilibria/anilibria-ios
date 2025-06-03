//
//  CollectionsFilterGenresRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct CollectionsFilterGenresRequest: BackendAPIRequest {
    typealias ResponseObject = [Genre]

    let endpoint: String = "/accounts/users/me/collections/references/genres"
    let method: NetworkManager.Method = .GET
}
