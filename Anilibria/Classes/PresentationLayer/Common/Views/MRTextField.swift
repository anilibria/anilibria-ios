import UIKit

public class MRTextField: UITextField {
    @IBInspectable var nonActiveAlpha: CGFloat = 0.1
    @IBOutlet var targetView: UIView? {
        didSet {
            self.targetView?.alpha = self.nonActiveAlpha
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.addTarget(self, action: #selector(self.begin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.end), for: .editingDidEnd)
    }

    @objc private func begin() {
        UIView.animate(withDuration: 0.2) {
            self.targetView?.alpha = 1
        }
    }

    @objc private func end() {
        UIView.animate(withDuration: 0.2) {
            self.targetView?.alpha = self.nonActiveAlpha
        }
    }
}
