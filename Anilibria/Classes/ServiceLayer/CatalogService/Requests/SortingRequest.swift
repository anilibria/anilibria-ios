//
//  SortingRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct SortingRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Sorting]

    let endpoint: String = "/anime/catalog/references/sorting"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
