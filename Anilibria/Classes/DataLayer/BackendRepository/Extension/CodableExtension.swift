import Foundation

public extension KeyedDecodingContainer {
    enum DecoderError: Error {
        case keyRequired
        case noValueDecoded
    }

    func decode<T: Decodable>(oneOf keys: Key...) throws -> T {
        for key in keys {
            if let result: T = decode(key) {
                return result
            }
        }
        throw DecoderError.noValueDecoded
    }

    func decode<T: Decodable>(_ keys: Key...) -> T? {
        decode(keys)
    }

    func decode<T: Decodable>(_ keys: [Key]) -> T? {
        if let data = try? self.find(by: keys) {
            return try? data.container.decodeIfPresent(T.self, forKey: data.key)
        }
        return nil
    }

    func decode<T: Decodable>(required keys: Key...) throws -> T {
        try decode(required: keys)
    }

    func decode<T: Decodable>(required keys: [Key]) throws -> T {
        let data = try self.find(by: keys)
        return try data.container.decode(T.self, forKey: data.key)
    }

    private func find(by keys: [Key]) throws -> (key: K, container: KeyedDecodingContainer) {
        guard keys.isEmpty == false else {
            assertionFailure("Key is required")
            throw DecoderError.keyRequired
        }

        if keys.count == 1 {
            return (keys[0], self)
        }

        let last = keys.count - 1
        var currentContainer: KeyedDecodingContainer = self
        for index in 0..<last {
            currentContainer = try currentContainer.nestedContainer(keyedBy: Key.self, forKey: keys[index])
        }

        return (keys[last], currentContainer)
    }
}

public extension Encoder {
    /// Syntactic sugar for encoding
    /// ### Usage: ###
    /// ```
    /// func encode(to encoder: Encoder) throws {
    ///     encoder.apply(CodingKeys.self) { container in
    ///         container[.number] = number
    ///         container[.seed] = seed
    ///         container[.user][.name] = userName
    ///         container[ifPresent: .price] = price
    ///    }
    /// }
    /// ```
    func apply<Key: CodingKey>(_ type: Key.Type, action: (inout KeyedEncodingContainer<Key>) -> Void) {
        var container = self.container(keyedBy: type)
        action(&container)
    }
}

public extension KeyedEncodingContainer {
    subscript<T>(key: Key) -> T? where T: Encodable {
        get { nil  }
        set { try? self.encode(newValue, forKey: key) }
    }

    subscript<T>(ifPresent key: Key) -> T? where T: Encodable {
        get { nil }
        set { try? self.encodeIfPresent(newValue, forKey: key) }
    }

    subscript(key: Key) -> KeyedEncodingContainer {
        mutating get { self.nestedContainer(keyedBy: Key.self, forKey: key)  }
        set { }
    }
}

public struct CodingKeyString: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    private let value: String

    public init(stringLiteral value: Self.StringLiteralType) {
        self.value = value
    }
}

extension CodingKeyString: CodingKey {
    public var stringValue: String {
        self.value
    }

    public var intValue: Int? {
        nil
    }

    public init?(intValue: Int) {
       nil
    }

    public init?(stringValue: String) {
        self.value = stringValue
    }
}
