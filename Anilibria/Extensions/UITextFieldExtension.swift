import Combine
import UIKit

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            if let value = newValue {
                let attr = [NSAttributedString.Key.foregroundColor: value]
                let holder = self.placeholder ?? ""
                self.attributedPlaceholder = NSAttributedString(string: holder,
                                                                attributes: attr)
            }
        }
    }
}

extension UITextContentType {
    public static let unspecified = UITextContentType(rawValue: "unspecified")
}

public extension UITextField {

    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text }
            .merge(with: publisher(for: \.text))
            .eraseToAnyPublisher()
    }

    var hasAnyCharacter: AnyPublisher<Bool, Never> {
        return textPublisher
            .map { $0?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            .eraseToAnyPublisher()
    }
}
