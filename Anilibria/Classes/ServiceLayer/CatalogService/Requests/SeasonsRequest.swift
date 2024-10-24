//
//  SeasonsRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct SeasonsRequest: BackendAPIRequest {
    typealias ResponseObject = [DescribedValue<String>]

    let endpoint: String = "/anime/catalog/references/seasons"
    let method: NetworkManager.Method = .GET
}
