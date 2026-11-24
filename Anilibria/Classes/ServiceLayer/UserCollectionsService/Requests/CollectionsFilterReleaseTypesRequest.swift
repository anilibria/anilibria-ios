//
//  CollectionsFilterReleaseTypesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct CollectionsFilterReleaseTypesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [DescribedValue<String>]

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/collections/references/types"
    )
}
