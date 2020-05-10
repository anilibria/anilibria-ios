import UIKit

public final class FilterTagTitleCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!

    func configure(_ text: String) {
        self.titleLabel.text = text
    }
}
