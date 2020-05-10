import UIKit

public final class AttributeStringBuilder {
    private var attributes: [NSAttributedString.Key: Any] = [:]
    private var paragraphStyle = NSMutableParagraphStyle()

    @discardableResult
    public func set(color: UIColor) -> AttributeStringBuilder {
        self.attributes[.underlineColor] = color
        self.attributes[.foregroundColor] = color
        return self
    }

    @discardableResult
    public func set(font: UIFont) -> AttributeStringBuilder {
        self.attributes[.font] = font
        return self
    }

    @discardableResult
    public func set(align: NSTextAlignment) -> AttributeStringBuilder {
        self.paragraphStyle.alignment = align
        self.attributes[.paragraphStyle] = self.paragraphStyle
        return self
    }

    @discardableResult
    public func set(lineHeight: CGFloat) -> AttributeStringBuilder {
        self.paragraphStyle.minimumLineHeight = lineHeight
        self.attributes[.paragraphStyle] = self.paragraphStyle
        return self
    }

    @discardableResult
    public func set(lineSpacing: CGFloat) -> AttributeStringBuilder {
        self.paragraphStyle.lineSpacing = lineSpacing
        self.attributes[.paragraphStyle] = self.paragraphStyle
        return self
    }

    @discardableResult
    public func set(kern: Float) -> AttributeStringBuilder {
        self.attributes[.kern] = NSNumber(value: kern)
        return self
    }

    @discardableResult
    public func set(underline: NSUnderlineStyle) -> AttributeStringBuilder {
        self.attributes[.underlineStyle] = underline.rawValue
        return self
    }

    @discardableResult
    public func set(lineBreakMode: NSLineBreakMode) -> AttributeStringBuilder {
        self.paragraphStyle.lineBreakMode = lineBreakMode
        self.attributes[.paragraphStyle] = self.paragraphStyle
        return self
    }

    @discardableResult
    public func set(link: URL) -> AttributeStringBuilder {
        self.attributes[.link] = link
        return self
    }

    public func build(_ text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: self.attributes)
    }

    public func build(_ text: NSAttributedString) -> NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: text,
                                         merging: self.attributes)
    }

    public func copy() -> AttributeStringBuilder {
        let result = AttributeStringBuilder()
        result.attributes = self.attributes
        result.paragraphStyle = self.paragraphStyle
        return result
    }
}

extension URL {
    var isAttributeLink: Bool {
        return self.scheme == "AttributeBuilder"
    }

    init?(attributeLinkValue: String) {
        if let value = attributeLinkValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.init(string: "AttributeBuilder://AttributeBuilder/\(value)")
            return
        }
        return nil
    }

    var attributeLinkValue: String? {
        return self.lastPathComponent.removingPercentEncoding
    }
}

public func + (lhs: NSMutableAttributedString,
               rhs: NSMutableAttributedString) -> NSMutableAttributedString {
    let final = NSMutableAttributedString(attributedString: lhs)
    final.append(rhs)
    return final
}

private extension NSMutableAttributedString {
    convenience init(attributedString attrStr: NSAttributedString,
                     merging newAttributes: [NSAttributedString.Key: Any]) {
        self.init(attributedString: attrStr)
        let range = NSRange(location: 0, length: attrStr.length)
        self.enumerateAttributes(in: range, options: []) { currentAttributes, range, _ in
            let mergedAttributes = currentAttributes.merge(with: newAttributes)
            self.setAttributes(mergedAttributes, range: range)
        }
    }
}

private extension Dictionary {
    func merge(with dict: Dictionary) -> Dictionary {
        return dict.reduce(into: self) { result, pair in
            let (key, value) = pair
            result[key] = value
        }
    }
}
