import Foundation

public protocol LanguageBehavior: class {
    func languageDidChanged()
}

extension LanguageBehavior where Self: BaseViewController {
    func languageDidChanged() {
        self.setupStrings()
    }
}
