import Foundation

public let secondsPerDay: Int = 86400
public let secondsPerHour: Int = 3600
public let secondsPerMinutes: Int = 60

extension Date {
    func withoutTimeZone() -> Date {
        return self + TimeZone.current.secondsFromGMT().seconds
    }

    func beginOfDay() -> Date {
        return Date(timeIntervalSince1970: self.withoutTimeZone().timeInvervalAccurateToDay) - TimeZone.current.secondsFromGMT().seconds
    }

    var minutesIntervalSince1970: Int {
        return Int(timeIntervalSince1970 / 60)
    }

    /// time interval since 1970 accurate to the day
    var timeInvervalAccurateToDay: TimeInterval {
        let stamp = Int(self.timeIntervalSince1970)
        return TimeInterval(stamp - stamp % secondsPerDay)
    }

    var timeIntervalSinceBeginOfDay: TimeInterval {
        let stamp = Int(self.withoutTimeZone().timeIntervalSince1970)
        return TimeInterval(stamp % secondsPerDay)
    }

    public var dateComponents: DateComponents {
        return Calendar.autoupdatingCurrent.dateComponents(DateComponents.allComponentsSet, from: self)
    }

    public func isSameDay(_ other: Date) -> Bool {
        return Calendar.autoupdatingCurrent.isDate(self, inSameDayAs: other)
    }

    public var isToday: Bool {
        return Calendar.autoupdatingCurrent.isDateInToday(self)
    }

    public var isYesterday: Bool {
        return Calendar.autoupdatingCurrent.isDateInYesterday(self)
    }
}

/// Subtracts two dates and returns the relative components from `lhs` to `rhs`.
/// Follows this mathematical pattern:
///     let difference = lhs - rhs
///     rhs + difference = lhs
public func - (lhs: Date, rhs: Date) -> DateComponents {
    return Calendar.autoupdatingCurrent.dateComponents(DateComponents.allComponentsSet, from: rhs, to: lhs)
}

/// Adds date components to a date and returns a new date.
public func + (lhs: Date, rhs: DateComponents) -> Date {
    return Calendar.autoupdatingCurrent.date(byAdding: rhs, to: lhs)!
}

/// Adds date components to a date and returns a new date.
public func + (lhs: DateComponents, rhs: Date) -> Date {
    return (rhs + lhs)
}

/// Subtracts date components from a date and returns a new date.
public func - (lhs: Date, rhs: DateComponents) -> Date {
    return (lhs + (-rhs))
}

public extension Int {
    /// Internal transformation function
    ///
    /// - parameter type: component to use
    ///
    /// - returns: return self value in form of `DateComponents` where given `Calendar.Component` has `self` as value
    func toDateComponents(type: Calendar.Component) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.setValue(self, for: type)
        return dateComponents
    }

    /// Create a `DateComponents` with `self` value set as nanoseconds
    var nanoseconds: DateComponents {
        return self.toDateComponents(type: .nanosecond)
    }

    /// Create a `DateComponents` with `self` value set as seconds
    var seconds: DateComponents {
        return self.toDateComponents(type: .second)
    }

    /// Create a `DateComponents` with `self` value set as minutes
    var minutes: DateComponents {
        return self.toDateComponents(type: .minute)
    }

    /// Create a `DateComponents` with `self` value set as hours
    var hours: DateComponents {
        return self.toDateComponents(type: .hour)
    }

    /// Create a `DateComponents` with `self` value set as days
    var days: DateComponents {
        return self.toDateComponents(type: .day)
    }

    /// Create a `DateComponents` with `self` value set as weeks
    var weeks: DateComponents {
        return self.toDateComponents(type: .weekOfYear)
    }

    /// Create a `DateComponents` with `self` value set as months
    var months: DateComponents {
        return self.toDateComponents(type: .month)
    }

    /// Create a `DateComponents` with `self` value set as years
    var years: DateComponents {
        return self.toDateComponents(type: .year)
    }

    /// Create a `DateComponents` with `self` value set as quarters
    var quarters: DateComponents {
        return self.toDateComponents(type: .quarter)
    }
}

public extension DateComponents {
    /// Shortcut for 'all calendar components'.
    static var allComponentsSet: Set<Calendar.Component> {
        return [
            .era, .year, .month, .day, .hour, .minute,
            .second, .weekday, .weekdayOrdinal, .quarter,
            .weekOfMonth, .weekOfYear, .yearForWeekOfYear,
            .nanosecond, .calendar, .timeZone
        ]
    }

    /// Adds two NSDateComponents and returns their combined individual components.
    static func + (lhs: DateComponents, rhs: DateComponents) -> DateComponents {
        return self.combine(lhs, rhs: rhs, transform: +)
    }

    /// Subtracts two NSDateComponents and returns the relative difference between them.
    static func - (lhs: DateComponents, rhs: DateComponents) -> DateComponents {
        return lhs + (-rhs)
    }

    /// Applies the `transform` to the two `T` provided, defaulting either of them if it's
    /// `nil`
    internal static func bimap<T>(_ a: T?, _ b: T?, default: T, _ transform: (T, T) -> T) -> T? {
        if a == nil && b == nil { return nil }
        return transform(a ?? `default`, b ?? `default`)
    }

    /// - returns: a new `NSDateComponents` that represents the negative of all values within the
    /// components that are not `NSDateComponentUndefined`.
    static prefix func - (rhs: DateComponents) -> DateComponents {
        var components = DateComponents()
        components.era = rhs.era.map(-)
        components.year = rhs.year.map(-)
        components.month = rhs.month.map(-)
        components.day = rhs.day.map(-)
        components.hour = rhs.hour.map(-)
        components.minute = rhs.minute.map(-)
        components.second = rhs.second.map(-)
        components.nanosecond = rhs.nanosecond.map(-)
        components.weekday = rhs.weekday.map(-)
        components.weekdayOrdinal = rhs.weekdayOrdinal.map(-)
        components.quarter = rhs.quarter.map(-)
        components.weekOfMonth = rhs.weekOfMonth.map(-)
        components.weekOfYear = rhs.weekOfYear.map(-)
        components.yearForWeekOfYear = rhs.yearForWeekOfYear.map(-)
        return components
    }

    /// Combines two date components using the provided `transform` on all
    /// values within the components that are not `NSDateComponentUndefined`.
    private static func combine(_ lhs: DateComponents, rhs: DateComponents, transform: (Int, Int) -> Int) -> DateComponents {
        var components = DateComponents()
        components.era = bimap(lhs.era, rhs.era, default: 0, transform)
        components.year = bimap(lhs.year, rhs.year, default: 0, transform)
        components.month = bimap(lhs.month, rhs.month, default: 0, transform)
        components.day = bimap(lhs.day, rhs.day, default: 0, transform)
        components.hour = bimap(lhs.hour, rhs.hour, default: 0, transform)
        components.minute = bimap(lhs.minute, rhs.minute, default: 0, transform)
        components.second = bimap(lhs.second, rhs.second, default: 0, transform)
        components.nanosecond = bimap(lhs.nanosecond, rhs.nanosecond, default: 0, transform)
        components.weekday = bimap(lhs.weekday, rhs.weekday, default: 0, transform)
        components.weekdayOrdinal = bimap(lhs.weekdayOrdinal, rhs.weekdayOrdinal, default: 0, transform)
        components.quarter = bimap(lhs.quarter, rhs.quarter, default: 0, transform)
        components.weekOfMonth = bimap(lhs.weekOfMonth, rhs.weekOfMonth, default: 0, transform)
        components.weekOfYear = bimap(lhs.weekOfYear, rhs.weekOfYear, default: 0, transform)
        components.yearForWeekOfYear = bimap(lhs.yearForWeekOfYear, rhs.yearForWeekOfYear, default: 0, transform)
        return components
    }
}
