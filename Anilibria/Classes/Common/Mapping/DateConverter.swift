import Foundation

public final class DateConverter: Converter {
    private let dateFormatter = ISO8601DateFormatter()
    public typealias FromValue = String?
    public typealias ToValue = Date?

    public func convert(from item: String?) -> Date? {
        guard let item else {
            return nil
        }
        return dateFormatter.date(from: item)
    }

    public func convert(from value: Date?) -> String? {
        guard let value else {
            return nil
        }
        return dateFormatter.string(from: value)
    }
}
