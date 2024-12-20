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
}
