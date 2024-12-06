import Foundation

public enum WeekDay: Int, Codable, CaseIterable {
    case mon = 1
    case tue
    case wen
    case thu
    case fri
    case sat
    case sun

    var name: String {
        switch self {
        case .mon: L10n.Common.WeekDay.mon
        case .tue: L10n.Common.WeekDay.tue
        case .wen: L10n.Common.WeekDay.wen
        case .thu: L10n.Common.WeekDay.thu
        case .fri: L10n.Common.WeekDay.fri
        case .sat: L10n.Common.WeekDay.sat
        case .sun: L10n.Common.WeekDay.sun
        }
    }

    var onDay: String {
        switch self {
        case .mon: L10n.Common.WeekDay.onMon
        case .tue: L10n.Common.WeekDay.onTue
        case .wen: L10n.Common.WeekDay.onWen
        case .thu: L10n.Common.WeekDay.onThu
        case .fri: L10n.Common.WeekDay.onFri
        case .sat: L10n.Common.WeekDay.onSat
        case .sun: L10n.Common.WeekDay.onSun
        }
    }
    
    var shortName: String {
        switch self {
        case .mon: L10n.Common.WeekDay.Short.mon
        case .tue: L10n.Common.WeekDay.Short.tue
        case .wen: L10n.Common.WeekDay.Short.wen
        case .thu: L10n.Common.WeekDay.Short.thu
        case .fri: L10n.Common.WeekDay.Short.fri
        case .sat: L10n.Common.WeekDay.Short.sat
        case .sun: L10n.Common.WeekDay.Short.sun
        }
    }
}
