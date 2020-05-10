import Foundation

public enum Language: String, Equatable {
    case ru
    case en

    private static let names: [Language: String] = [
        .ru: "Русский",
        .en: "English"
    ]

    var name: String {
        return Language.names[self, default: ""]
    }

    var locale: Locale? {
        return Locale(identifier: self.rawValue)
    }
}
