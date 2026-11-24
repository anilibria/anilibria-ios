import Foundation

@main
enum GenerationScript {
    static func main() {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: "Localizable.xcstrings"))
            let localization = try JSONDecoder().decode(Localizable.self, from: data)

            let root = Node(name: "L10n")
            localization.strings.forEach { (key, value) in
                let components = key.split(separator: ".").map(String.init)
                var current: Node?
                var target: Node?
                components.forEach { component in
                    let nameParts = component.split(separator: "_")
                    let node: Node
                    if components.last == component {
                        let normalizedName = nameParts.enumerated().map { index, part in
                            index == 0 ? String(part) : String(part).capitalized
                        }.joined()
                        node = Node(
                            name: normalizedName,
                            value: NodeValue(key: key, data: value.localizations["en"])
                        )
                    } else {
                        let normalizedName = nameParts.map { String($0).capitalized }.joined()
                        node = Node(name: normalizedName)
                    }
                    if current == nil && target == nil {
                        current = node
                        target = node
                    } else {
                        current?.children[node.name] = node
                        current = node
                    }
                }
                if let target {
                    root.merge(with: target)
                }
            }

            let generated = root.generate()
            try generated.data(using: .utf8)?.write(to: URL(fileURLWithPath: "Localizable.swift"))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

// MARK: - xcstrings decoding
struct Localizable: Decodable {
    let strings: [String: Translation]
}

struct Translation: Decodable {
    let localizations: [String: TranslationData]
}

struct TranslationData: Decodable {
    let stringUnit: StringUnit?
    let substitutions: [String: Substitution]?
    let variations: Variations?

    enum CodingKeys: String, CodingKey {
        case stringUnit
        case substitutions
        case variations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stringUnit = try? container.decodeIfPresent(StringUnit.self, forKey: .stringUnit)
        self.substitutions = try? container.decodeIfPresent([String: Substitution].self, forKey: .substitutions)
        self.variations = try? container.decodeIfPresent(Variations.self, forKey: .variations)
    }
}

struct StringUnit: Decodable {
    let value: String
}

struct Substitution: Decodable {
    let variations: Variations
}

struct Variations: Decodable {
    let plural: [String: TranslationData]
}

// MARK: - File structure

final class Node {
    let name: String
    let value: NodeValue?

    var children: [String: Node] = [:]

    init(name: String, value: NodeValue? = nil) {
        self.name = name
        self.value = value
    }

    func merge(with other: Node) {
        if let target = children[other.name] {
            other.children.forEach { child in
                target.merge(with: child.value)
            }
        } else {
            children[other.name] = other
        }
    }

    func generate(level: Int = 0) -> String {
        if let value {
            return generateValue(level: level, data: value)
        } else {
            return generateObject(level: level)
        }
    }

    private func makeIndent(_ level: Int) -> String {
        return String(repeating: "    ", count: level)
    }

    private func generateValue(level: Int, data: NodeValue) -> String {
        let indent = makeIndent(level)
        return data.generate(with: indent, name: name)
    }

    private func generateObject(level: Int) -> String {
        let indent = makeIndent(level)
        let childData = children.sorted(by: { $0.key < $1.key }).map {
            $0.value.generate(level: level + 1)
        }.joined()
        return """
               
               \(indent)enum \(name) {
               \(childData)
               \(indent)}
               
               """
    }
}

struct NodeValue {
    let key: String
    let text: String
    let data: TranslationData
    let specifiers: [StringSpecifier]

    init?(key: String, data: TranslationData?) {
        guard let data else {
            return nil
        }
        self.key = key
        self.data = data

        if let value = data.stringUnit?.value, let sabstitutions = data.substitutions {
            var result = value
            sabstitutions.forEach { (key, substitution) in
                if let value = substitution.variations.plural["other"]?.stringUnit?.value {
                    result = result.replacingOccurrences(of: "%#@\(key)@", with: value)
                }
            }
            self.text = result
        } else if let value = data.stringUnit?.value {
            self.text = value
        } else if let value = data.variations?.plural["other"]?.stringUnit?.value {
            self.text = value
        } else {
            fatalError("Can't parse text for value")
        }

        specifiers = StringSpecifier.get(from: text)
    }

    func generate(with indent: String, name: String) -> String {
        let desc = text.split(separator: "\n")
            .map { "\(indent)/// \(String($0))" }
            .joined(separator: "\n")

        if specifiers.isEmpty {
            return """
                   \(desc)
                   \(indent)static var `\(name)`: String {
                   \(indent)    return L10n.tr(\"Localizable\", \"\(key)\")
                   \(indent)}
                   
                   """
        }
        var properties: [String] = []
        var args: [String] = []

        specifiers.enumerated().forEach { index, specifier in
            properties.append("_ arg\(index + 1): \(specifier.rawValue)")
            args.append("arg\(index + 1)")
        }

        return """
               \(desc)
               \(indent)static func \(name)(\(properties.joined(separator: ", "))) -> String {
               \(indent)    return L10n.tr(\"Localizable\", \"\(key)\", \(args.joined(separator: ", ")))
               \(indent)}
               
               """
    }
}

// MARK: - Detect Specifiers

enum StringSpecifier: String {
    case object = "String"
    case float = "Float"
    case int = "Int"
    case char = "CChar"
    case cString = "UnsafePointer<CChar>"
    case pointer = "UnsafeRawPointer"

    init?(formatChar char: Character) {
        guard let lcChar = String(char).lowercased().first else {
            return nil
        }
        switch lcChar {
        case "@": self = .object
        case "a", "e", "f", "g": self = .float
        case "d", "i", "o", "u", "x":  self = .int
        case "c": self = .char
        case "s": self = .cString
        case "p": self = .pointer
        default: return nil
        }
    }

    static func get(from formatString: String) -> [StringSpecifier] {
        let range = NSRange(location: 0, length: (formatString as NSString).length)

        // Extract the list of chars (conversion specifiers) and their optional positional specifier
        let chars = regexp.matches(in: formatString, options: [], range: range)
            .compactMap { match -> (String, Int?)? in
                let range: NSRange
                if match.range(at: 3).location != NSNotFound {
                    // [dioux] are in range #3 because in #2 there may be length modifiers (like in "lld")
                    range = match.range(at: 3)
                } else {
                    // otherwise, no length modifier, the conversion specifier is in #2
                    range = match.range(at: 2)
                }
                let char = (formatString as NSString).substring(with: range)

                let posRange = match.range(at: 1)
                if posRange.location == NSNotFound {
                    // No positional specifier
                    return (char, nil)
                } else {
                    // Remove the "$" at the end of the positional specifier, and convert to Int
                    let posRange1 = NSRange(location: posRange.location, length: posRange.length - 1)
                    let posString = (formatString as NSString).substring(with: posRange1)
                    let pos = Int(posString)
                    if let pos = pos, pos <= 0 {
                        return nil // Foundation renders "%0$@" not as a placeholder but as the "0@" literal
                    }
                    return (char, pos)
                }
            }

        return specifiers(fromChars: chars)
    }

    private static let regexp: NSRegularExpression = {
        // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
        let patternInt = "(?:h|hh|l|ll|q|z|t|j)?([dioux])"
        // valid flags for float
        let patternFloat = "[aefg]"
        // like in "%3$" to make positional specifiers
        let position = "(\\d+\\$)?"
        // precision like in "%1.2f"
        let precision = "[-+# 0]?\\d?(?:\\.\\d)?"

        do {
            return try NSRegularExpression(
                pattern: "(?:^|(?<!%)(?:%%)*)%\(position)\(precision)(@|\(patternInt)|\(patternFloat)|[csp])",
                options: [.caseInsensitive]
            )
        } catch {
            fatalError("Error building the regular expression used to match string formats")
        }
    }()

    private static func specifiers(fromChars chars: [(String, Int?)]) -> [StringSpecifier] {
        var list = [Int: StringSpecifier]()
        var nextNonPositional = 1

        for (str, pos) in chars {
            guard let char = str.first, let specifier = StringSpecifier(formatChar: char) else { continue }
            let insertionPos: Int
            if let pos = pos {
                insertionPos = pos
            } else {
                insertionPos = nextNonPositional
                nextNonPositional += 1
            }
            guard insertionPos > 0 else { continue }

            if let existingEntry = list[insertionPos], existingEntry != specifier {
                fatalError("invalid entry - previous: \(existingEntry), new: \(specifier)")
            } else {
                list[insertionPos] = specifier
            }
        }

        // Omit any holes (i.e. position without a placeholder defined)
        return list
            .sorted { $0.0 < $1.0 } // Sort by key, i.e. the positional value
            .map { $0.value }
    }
}
