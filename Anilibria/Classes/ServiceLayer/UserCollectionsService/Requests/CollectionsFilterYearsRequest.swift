//
//  CollectionsFilterYearsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct CollectionsFilterYearsRequest: BackendAPIRequest {
    typealias ResponseObject = [Int]

    let endpoint: String = "/accounts/users/me/collections/references/years"
    let method: NetworkManager.Method = .GET
}
