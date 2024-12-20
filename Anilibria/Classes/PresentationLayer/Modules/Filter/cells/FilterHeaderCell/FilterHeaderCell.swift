import UIKit

public final class FilterHeaderCell: UICollectionViewCell {
    @IBOutlet var filterTitleLabel: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()
        filterTitleLabel.text = L10n.Screen.Filter.title
        filterTitleLabel.textAlignment = .center
        filterTitleLabel.textColor = UIColor(resource: .Text.main)
        filterTitleLabel.font = UIFont.font(ofSize: 17, weight: .medium)
    }
}
