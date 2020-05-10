import UIKit

extension UICollectionViewCell {
    static func className() -> String {
        return String(describing: self)
    }

    static func loadFromNib(frame: CGRect? = nil) -> Self? {
        let item = Bundle.main.loadNibNamed(className(), owner: nil, options: nil)?.first
        let view = item >> self
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
