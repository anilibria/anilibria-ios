//
//  FranchiseRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct FranchiseRequest: BackendAPIRequest {
    typealias ResponseObject = [Franchise]

    let endpoint: String
    let method: NetworkManager.Method = .GET

    init(seriesID: Int) {
        self.endpoint = "/anime/franchises/release/\(seriesID)"
    }
}
