import UIKit

extension String {
    static func pluralsString(number: Int,
                              zero: String,
                              one: String,
                              two: String) -> String {
        let num = number % 100
        if num > 10 && num < 15 {
            return zero
        }

        switch number % 10 {
        case 1:
            return one
        case 2, 3, 4:
            return two
        default:
            return zero
        }
    }
}

extension String {
    public func trim(_ charset: String? = nil) -> String {
        if charset == nil {
            return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return self.trimmingCharacters(in: CharacterSet(charactersIn: charset!))
    }

    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
    }
}

extension String {
    func height(for width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize,
                                           options: [.usesLineFragmentOrigin],
                                           attributes: [NSAttributedString.Key.font: font],
                                           context: nil)
        return actualSize.height
    }
}

extension NSAttributedString {
    func height(for width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = boundingRect(with: maxSize,
                                      options: [.usesLineFragmentOrigin],
                                      context: nil)
        return actualSize.height
    }
    
    func width(for height: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let actualSize = boundingRect(with: maxSize,
                                      options: [.usesLineFragmentOrigin],
                                      context: nil)
        return actualSize.width
    }
}

extension String {
    func html2AttributedString(with cssStyle: String = "") -> NSAttributedString? {
        let str = cssStyle + self
        if let data = str.data(using: .unicode, allowLossyConversion: true) {
            let result = try? NSAttributedString(data: data,
                                                 options: [.documentType: NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
            return result
        }
        return nil
    }
}

extension String {
    func toURL() -> URL? {
        var urlString = self
        if !(urlString.starts(with: "http://") || urlString.starts(with: "https://")) {
            urlString = "http://\(urlString)"
        }
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: urlString)
    }
}

extension String {
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        }
    }
}

private let letters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

extension String {
    static func randomString(length: Int) -> String {
        return String(letters.shuffled().prefix(length))
    }
}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}

extension String {
    var djbHash: Int {
        unicodeScalars
            .lazy
            .map { $0.value }
            .reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
}
