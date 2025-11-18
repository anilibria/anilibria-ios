//
//  GenresRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct GenresRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [Genre]

    let endpoint: String = "/anime/catalog/references/genres"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
