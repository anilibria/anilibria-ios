import Foundation

public final class SpecialCharactersConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = String

    public func convert(from item: String?) -> String {
        guard let value = item else {
            return ""
        }

        let chars = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&apos;", "')")
        ]

        var result = value

        for (escaped, unescaped) in chars {
            result = result.replacingOccurrences(of: escaped,
                                                 with: unescaped,
                                                 options: .regularExpression,
                                                 range: nil)
        }

        return result
    }
}
