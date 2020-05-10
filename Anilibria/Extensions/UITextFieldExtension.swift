import RxCocoa
import RxSwift
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
