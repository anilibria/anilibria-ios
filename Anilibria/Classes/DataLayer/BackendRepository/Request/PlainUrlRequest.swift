//
//  PlainUrlRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 29.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct PlainUrlRequest<T: Decodable>: BackendAPIRequest {
    typealias ResponseObject = T

    let baseUrl: String
    let endpoint: String = ""
    let apiVersion: String = ""
    let method: NetworkManager.Method = .GET

    var headers: [String: String] { ["Content-Type": "*/*"] }

    init(url: String) {
        baseUrl = url
    }
}
