import Foundation

public protocol LanguageBehavior: AnyObject {
    func languageDidChanged()
}

extension LanguageBehavior where Self: BaseViewController {
    func languageDidChanged() {
        self.setupStrings()
    }
}
