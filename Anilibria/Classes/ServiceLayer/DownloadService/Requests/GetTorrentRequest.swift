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

    var requestData: RequestData = .init(
        headers: ["Content-Type": "application/x-bittorrent"]
    )

    init(id: Int) {
        requestData.endpoint = "anime/torrents/\(id)/file"
    }
}
