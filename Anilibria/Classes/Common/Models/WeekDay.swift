import Foundation

public enum WeekDay: String, Codable {
    case mon = "1"
    case tue = "2"
    case wen = "3"
    case thu = "4"
    case fri = "5"
    case sat = "6"
    case sun = "7"

    var index: Int? {
        if let value = Int(self.rawValue) {
            return value - 1
        }
        return nil
    }

    private static let names: [WeekDay: String] = [
        .mon : L10n.Common.WeekDay.mon,
        .tue : L10n.Common.WeekDay.tue,
        .wen : L10n.Common.WeekDay.wen,
        .thu : L10n.Common.WeekDay.thu,
        .fri : L10n.Common.WeekDay.fri,
        .sat : L10n.Common.WeekDay.sat,
        .sun : L10n.Common.WeekDay.sun
    ]

    private static let onDays: [WeekDay: String] = [
        .mon : L10n.Common.WeekDay.onMon,
        .tue : L10n.Common.WeekDay.onTue,
        .wen : L10n.Common.WeekDay.onWen,
        .thu : L10n.Common.WeekDay.onThu,
        .fri : L10n.Common.WeekDay.onFri,
        .sat : L10n.Common.WeekDay.onSat,
        .sun : L10n.Common.WeekDay.onSun
    ]

    var name: String {
        return Self.names[self]!
    }

    var onDay: String {
        return Self.onDays[self]!
    }

    static func getMsk() -> WeekDay {
        var calendar = Calendar(identifier: .gregorian)
        if let timezone = TimeZone(secondsFromGMT: 3 * 60 * 60) {
            calendar.timeZone = timezone
        }

        let weekDay = calendar.component(.weekday, from: Date()) - 1
        return self.create(from: weekDay)
    }

    static func getCurrent() -> WeekDay {
        let weekDay = Calendar(identifier: .gregorian)
            .component(.weekday, from: Date()) - 1
        return self.create(from: weekDay)
    }

    private static func create(from number: Int) -> WeekDay {
        var weekDay = number
        if weekDay == 0 {
            weekDay = 7
        }
        return WeekDay(rawValue: "\(weekDay)")!
    }
}
