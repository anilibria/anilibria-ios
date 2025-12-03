//
//  GetTorrentRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct GetTorrentRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Data

    let endpoint: String
    let method: NetworkManager.Method = .GET

    var headers: [String: String] = ["Content-Type": "application/x-bittorrent"]

    init(id: Int) {
        endpoint = "anime/torrents/\(id)/file"
    }
}
