//
//  SoonViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

final class SoonViewModel: Hashable {
    let selectedDay = CurrentValueSubject<ShortSchedule.Day, Never>(.today)
    let days: [ShortSchedule.Day] = [.yesterday, .today, .tomorrow]
    private let schedule: ShortSchedule

    var seeAllAction: (() -> Void)?
    var selectSeries: ((Series) -> Void)?

    var items: [ScheduleItem] {
        schedule.items[selectedDay.value] ?? []
    }

    init(_ schedule: ShortSchedule) {
        self.schedule = schedule
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(days)
        hasher.combine(schedule)
    }

    static func == (lhs: SoonViewModel, rhs: SoonViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func select(index: Int) {
        selectedDay.send(days[index])
    }
}
