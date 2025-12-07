//
//  FranchiseRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FranchiseRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Franchise]

    var requestData: RequestData

    init(seriesID: Int) {
        requestData = .init(
            endpoint: "/anime/franchises/release/\(seriesID)"
        )
    }
}
