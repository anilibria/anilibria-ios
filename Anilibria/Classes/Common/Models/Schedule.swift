import Foundation

public struct Schedule: Hashable {
    let day: WeekDay?
    let items: [ScheduleItem]
    var title: TitleItem {
        TitleItem({ self.day?.name ?? "" }())
    }
}
