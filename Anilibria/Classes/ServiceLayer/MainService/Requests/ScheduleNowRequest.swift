//
//  ScheduleNowRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ScheduleNowRequest: AuthorizableAPIRequest {
    typealias ResponseObject = ShortSchedule

    let endpoint: String = "/anime/schedule/now"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
