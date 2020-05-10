import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    var jsonString: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension KeyedDecodingContainer where Key == String {
    subscript<T>(key: Key, default defaultValue: @autoclosure () -> T) -> T where T: Decodable {
        if let data = self.find(key: key),
            let result = try? data.container.decodeIfPresent(T.self, forKey: data.key) {
            return result
        }
        return defaultValue()
    }

    subscript<T>(key: Key) -> T? where T: Decodable {
        if let data = self.find(key: key),
            let value = try? data.container.decodeIfPresent(T.self, forKey: data.key) {
            return value
        }
        return nil
    }

    private func find(key: Key) -> (key: Key, container: KeyedDecodingContainer)? {
        let keys = key.split(separator: ".").map(String.init)

        if keys.count < 2 {
            return (key, self)
        }

        let last = keys.count - 1
        var container: KeyedDecodingContainer? = self
        for index in 0..<last {
            if let value = container {
                container = try? value.nestedContainer(keyedBy: String.self, forKey: keys[index])
            }
        }

        if let value = container {
            return (keys[last], value)
        }

        return nil
    }
}

extension KeyedDecodingContainer {
    subscript<T>(key: Key, default defaultValue: @autoclosure () -> T) -> T where T: Decodable {
        if let result = try? self.decodeIfPresent(T.self, forKey: key) {
            return result
        }
        return defaultValue()
    }

    subscript<T>(key: Key) -> T? where T: Decodable {
        if let value = try? self.decodeIfPresent(T.self, forKey: key) {
            return value
        }
        return nil
    }
}

extension KeyedEncodingContainer {
    subscript<T>(key: Key) -> T? where T: Encodable {
        get {
            return nil
        }
        set {
            try? self.encode(newValue, forKey: key)
        }
    }
}

extension String: CodingKey {
    public var stringValue: String {
        return self
    }

    public var intValue: Int? {
        return nil
    }

    public init?(intValue: Int) {
        return nil
    }

    public init?(stringValue: String) {
        self = stringValue
    }
}

public protocol DecodingContext {}

extension CodingUserInfoKey {
    public static let decodingContext: CodingUserInfoKey = CodingUserInfoKey(rawValue: "decodingContext")!
}

extension Decoder {
    public var decodingContext: DecodingContext? {
        return userInfo[.decodingContext] as? DecodingContext
    }
}

extension JSONDecoder {
    convenience init(context: DecodingContext) {
        self.init()
        self.userInfo[.decodingContext] = context
    }
}

extension Decoder {
    @inline(__always) func apply(action: (KeyedDecodingContainer<String>) -> Void) throws {
        let container = try self.container(keyedBy: String.self)
        action(container)
    }
}

extension Encoder {
    func apply(_ action: (inout KeyedEncodingContainer<String>) -> Void) {
        var container = self.container(keyedBy: String.self)
        action(&container)
    }
}
