import Foundation

public final class DateConverter: Converter {
    public typealias FromValue = Int?
    public typealias ToValue = Date?

    public func convert(from item: Int?) -> Date? {
        guard let timestamp = item else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

public final class StringDateConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = Date?

    public func convert(from item: String?) -> Date? {
        guard let timestamp = Double(item ?? "") else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}
