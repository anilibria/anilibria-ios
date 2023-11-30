import Foundation
import Combine

public protocol LanguageBehavior: AnyObject {
    func observeLanguageChanges() -> AnyCancellable
    func languageDidChanged()
}

extension LanguageBehavior {
    func observeLanguageChanges() -> AnyCancellable {
        Language.languageChanged.sink { [weak self] _ in
            self?.languageDidChanged()
        }
    }
}

extension LanguageBehavior where Self: BaseViewController {
    func languageDidChanged() {
        self.setupStrings()
    }
}
