import UIKit

final class ScheduleSeriesCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var releaseIndicatorView: [UIView]!
    @IBOutlet var releaseTitleLabel: UILabel!

    func configure(_ item: Series) {
        self.releaseTitleLabel.text = item.names.first
        self.releaseTitleLabel.superview?.isHidden = true

        self.imageView.setImage(from: item.poster,
                                placeholder: UIImage(resource: .imgPlaceholder)) { result in
            switch result {
            case .failure:
                self.releaseTitleLabel.superview?.isHidden = false
                self.releaseTitleLabel.superview?.fadeTransition()
            default:
                self.releaseTitleLabel.superview?.isHidden = true
            }
        }
        self.renderIndicator(item)
    }

    private func renderIndicator(_ item: Series) {
        let hasUpdates = item.hasUpdates()
        self.releaseIndicatorView.forEach { $0.isHidden = !hasUpdates }
    }

    static func size(with width: CGFloat, gap: CGFloat) -> CGSize {
        let width = (width > 500 ? 500 : width)
        let cellWidth = (width - gap * 4)/3
        let cellHeight = (cellWidth * 10) / 7
        return CGSize(width: cellWidth, height: cellHeight)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
