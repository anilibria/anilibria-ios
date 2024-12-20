import UIKit

public final class ChoiceCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var separatorView: UIView!

    func configure(_ item: ChoiceItem, isLast: Bool) {
        self.titleLabel.text = item.title
        self.iconView.isHidden = !item.isSelected
        self.separatorView.isHidden = isLast
    }
}
