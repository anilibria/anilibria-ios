//
//  CollectionsFilterReleaseTypesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct CollectionsFilterReleaseTypesRequest: BackendAPIRequest {
    typealias ResponseObject = [DescribedValue<String>]

    let endpoint: String = "/accounts/users/me/collections/references/types"
    let method: NetworkManager.Method = .GET
}
