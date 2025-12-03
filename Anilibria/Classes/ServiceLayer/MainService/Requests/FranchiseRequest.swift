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

    let endpoint: String
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]

    init(seriesID: Int) {
        self.endpoint = "/anime/franchises/release/\(seriesID)"
    }
}
