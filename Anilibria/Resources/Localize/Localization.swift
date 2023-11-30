import Foundation
import Combine

public enum Language: String, Equatable, Codable {
    case ru
    case en
    
    private static let currrentLocaleKey: String = "CurrentLanguage"
    private static let languageChangedSubject = PassthroughSubject<Void, Never>()
    static var languageChanged: AnyPublisher<Void, Never> {
        return languageChangedSubject.eraseToAnyPublisher()
    }
    
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
    
    static var defaultLanguage: Language {
        return Bundle.main.preferredLocalizations.compactMap {
            return Language(rawValue: $0)
        }.first ?? .en
    }
    
    private static func selectedLanguage() -> Language {
        if let currentLanguage: Language = UserDefaults.standard[currrentLocaleKey] {
            return currentLanguage
        }
        let lang = defaultLanguage
        UserDefaults.standard[currrentLocaleKey] = lang
        return lang
    }
    
    static var current: Language = selectedLanguage() {
        didSet {
            if current == oldValue {
                return
            }
            UserDefaults.standard[currrentLocaleKey] = current
            languageChangedSubject.send()
        }
    }
}

extension String {
    func localized(using tableName: String?) -> String {
        if let path = Bundle.main.path(forResource: Language.current.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        return self
    }
}
