//
//  YearsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct YearsRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Int]

    let endpoint: String = "/anime/catalog/references/years"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]

}
