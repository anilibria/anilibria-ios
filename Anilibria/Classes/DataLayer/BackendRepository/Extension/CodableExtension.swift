import Foundation

extension CodingUserInfoKey {
	fileprivate static let decodingContext: CodingUserInfoKey = CodingUserInfoKey(rawValue: "decodingContext")!
}

public extension Decoder {
	var decodingContext: Any? {
		return userInfo[.decodingContext]
	}
}

public extension JSONDecoder {
	convenience init(context: Any) {
		self.init()
		self.userInfo[.decodingContext] = context
	}
}

public extension Decoder {
	subscript<T>(key: T.Type) -> T? where T: Decodable {
		return try? self.singleValueContainer().decode(key)
	}

	subscript<T, K>(key: K..., default defaultValue: @autoclosure () -> T) -> T where T: Decodable, K: CodingKey {
		return (try? self.container(keyedBy: K.self)[key]) ?? defaultValue()
	}

	subscript<T, K>(key: K...) -> T? where T: Decodable, K: CodingKey {
		return try? self.container(keyedBy: K.self)[key]
	}

}

public extension Encoder {
	func apply(_ action: (inout KeyedEncodingContainer<String>) -> Void) {
		var container = self.container(keyedBy: String.self)
		action(&container)
	}

	func apply<Key: CodingKey>(_ type: Key.Type, action: (inout KeyedEncodingContainer<Key>) -> Void) {
		var container = self.container(keyedBy: type)
		action(&container)
	}
}

public extension Encodable {
	var dictionary: [String: Any]? {
		guard let data = try? JSONEncoder().encode(self) else { return nil }
		return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
	}

	var jsonString: String? {
		guard let data = try? JSONEncoder().encode(self) else { return nil }
		return String(data: data, encoding: .utf8)
	}
}

// MARK: -

public extension KeyedDecodingContainer {
	subscript<T>(key: Key, default defaultValue: @autoclosure () -> T) -> T where T: Decodable {
		return self[key] ?? defaultValue()
	}

	subscript<T>(key: Key) -> T? where T: Decodable {
		try? self.decodeIfPresent(T.self, forKey: key)
	}

	subscript<T>(key: Key..., default defaultValue: @autoclosure () -> T) -> T where T: Decodable {
		return self[key] ?? defaultValue()
	}

	subscript<T>(key: Key...) -> T? where T: Decodable {
		self[key]
	}

	fileprivate subscript<T>(key: [Key]) -> T? where T: Decodable {
		if let data = self.find(keys: key) {
			return try? data.container.decodeIfPresent(T.self, forKey: data.key)
		}
		return nil
	}

	private func find(keys: [Key]) -> (key: Key, container: KeyedDecodingContainer)? {
		guard keys.isEmpty == false else { return nil}

		if keys.count == 1 {
			return (keys[0], self)
		}

		let last = keys.count - 1
		var container: KeyedDecodingContainer? = self
		for index in 0..<last {
			container = try? container?.nestedContainer(keyedBy: Key.self, forKey: keys[index])
		}

		if let value = container {
			return (keys[last], value)
		}

		return nil
	}
}

public extension KeyedEncodingContainer {
	subscript<T>(key: Key) -> T? where T: Encodable {
		get { nil }
		set { try? self.encode(newValue, forKey: key) }
	}
}

extension String: CodingKey {
	public var stringValue: String {
		self
	}

	public var intValue: Int? {
		nil
	}

	public init?(intValue: Int) {
		nil
	}

	public init?(stringValue: String) {
		self = stringValue
	}
}
