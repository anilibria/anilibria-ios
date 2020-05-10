public final class ArrayConverterDecorator<C>: Converter where C: Converter {
    public typealias FromValue = [C.FromValue]?
    public typealias ToValue = [C.ToValue]

    private let converter: C

    init(_ converter: C) {
        self.converter = converter
    }

    public func convert(from item: [C.FromValue]?) -> [C.ToValue] {
        return item?.compactMap {
            converter.convert(from: $0)
        } ?? []
    }
}
