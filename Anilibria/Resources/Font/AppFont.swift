import UIKit

public protocol AppFont {
    func name(for weight: UIFont.Weight) -> String?
}

extension UIFont {
    static func font(_ appFont: AppFont? = MainTheme.shared.defaultFont,
                     ofSize: CGFloat,
                     weight: UIFont.Weight) -> UIFont {
        if let name = appFont?.name(for: weight),
            let customFont = UIFont(name: name, size: ofSize) {
            return customFont
        }
        return UIFont.systemFont(ofSize: ofSize, weight: weight)
    }
}
