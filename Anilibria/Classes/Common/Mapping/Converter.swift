import Foundation

public protocol Converter {
    associatedtype FromValue
    associatedtype ToValue

    func convert(from item: FromValue) -> ToValue
}
