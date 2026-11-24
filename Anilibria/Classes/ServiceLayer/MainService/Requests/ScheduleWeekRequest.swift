//
//  ScheduleWeekRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ScheduleWeekRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [ScheduleItem]

    var requestData: RequestData = .init(
        endpoint: "/anime/schedule/week"
    )
}
