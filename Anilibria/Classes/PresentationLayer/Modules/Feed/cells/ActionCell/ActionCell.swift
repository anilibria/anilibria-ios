import UIKit
import Combine

public final class ActionCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    private var langSubscriber: AnyCancellable?

    func configure(_ item: ActionItem) {
        self.titleLabel.text = item.localizedTitle()
        langSubscriber = Language.languageChanged.sink { [weak self] in
            self?.titleLabel.text = item.localizedTitle()
        }
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
