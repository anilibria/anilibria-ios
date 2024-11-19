//
//  ScheduleWeekRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ScheduleWeekRequest: BackendAPIRequest {
    typealias ResponseObject = [ScheduleItem]

    let endpoint: String = "/anime/schedule/week"
    let method: NetworkManager.Method = .GET
}
