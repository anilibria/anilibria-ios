//
//  ProductionStatusesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct ProductionStatusesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [DescribedValue<String>]

    var requestData: RequestData = .init(
        endpoint: "/anime/catalog/references/production-statuses"
    )
}
