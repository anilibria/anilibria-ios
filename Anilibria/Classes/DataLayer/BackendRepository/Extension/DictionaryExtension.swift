import Foundation

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
}

extension Dictionary where Key == String, Value == Any {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.compactMap { (key, value) -> String? in
            let percentEscapedKey = key.stringByAddingPercentEncodingForURLQueryValue()!
            if let array = value as? [AnyObject] {
                return array.map {
                    let percentEscapedValue = "\($0)".stringByAddingPercentEncodingForURLQueryValue()!
                    return "\(percentEscapedKey)[]=\(percentEscapedValue)"
                }.joined(separator: "&")
            }
            if value is [String: Any] {
                return nil
            }
            let percentEscapedValue = "\(value)".stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        return parameterArray.joined(separator: "&")
    }
}
