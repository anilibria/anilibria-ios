import Foundation

public final class ErrorConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = AppError?

    public func convert(from item: String?) -> AppError? {
        guard let value = item, value != "ok" else {
            return nil
        }

        return AppError.server(message: value)
    }
}
