//
//  GetTimecodesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct GetTimecodesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [TimeCodeData]

    var requestData: RequestData

    init(seriesID: Int) {
        requestData = .init(
            endpoint: "/anime/releases/\(seriesID)/episodes/timecodes"
        )
    }
}
