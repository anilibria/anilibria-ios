//
//  ShortSchedule.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ShortSchedule: Decodable, Hashable {
    enum Day: Hashable, CaseIterable {
        case tomorrow
        case today
        case yesterday
    }

    let items: [Day: [ScheduleItem]]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        var values: [Day: [ScheduleItem]] = [:]

        if let items: [ScheduleItem] = container.decode("today") {
            values[.today] = items
        }

        if let items: [ScheduleItem] = container.decode("tomorrow") {
            values[.tomorrow] = items
        }

        if let items: [ScheduleItem] = container.decode("yesterday") {
            values[.yesterday] = items
        }

        self.items = values
    }
}
