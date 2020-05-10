import UIKit

public final class TitleCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!

    func configure(_ item: String) {
        self.titleLabel.text = item
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
