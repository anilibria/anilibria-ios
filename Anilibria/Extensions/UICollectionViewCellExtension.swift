import UIKit

extension UICollectionViewCell {
    static var defaultNibName: String {
        return String(describing: self)
    }

    static func loadFromNib(frame: CGRect? = nil) -> Self? {
        let item = Bundle.main.loadNibNamed(defaultNibName, owner: nil, options: nil)?.first
        let view = item as? Self
        if let value = frame {
            view?.updateFrame(value)
        }
        return view
    }

    func updateFrame(_ value: CGRect) {
        self.frame = value
        self.contentView.frame = value
    }
}
