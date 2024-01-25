import Foundation

public struct RangeConverter: Converter {
    public typealias FromValue = [Int]?
    public typealias ToValue = Range<Int>?

    public func convert(from item: FromValue) -> ToValue {
        guard
            let item = item,
            let lowerBound = item[safe: 0],
            let upperBound = item[safe: 1] else {
            return nil
        }
        
        return Range(uncheckedBounds: (lowerBound, upperBound))
    }
}
