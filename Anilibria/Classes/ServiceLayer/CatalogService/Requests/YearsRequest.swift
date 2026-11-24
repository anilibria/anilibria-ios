//
//  YearsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct YearsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Int]

    var requestData: RequestData = .init(
        endpoint: "/anime/catalog/references/years"
    )
}
