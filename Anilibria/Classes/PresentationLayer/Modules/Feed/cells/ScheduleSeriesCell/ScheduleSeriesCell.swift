import UIKit

final class ScheduleSeriesCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var releaseIndicatorView: [UIView]!
    @IBOutlet var releaseTitleLabel: UILabel!
    

    func configure(_ schedule: ScheduleItem) {
        self.releaseTitleLabel.text = schedule.item.name?.main
        self.releaseTitleLabel.superview?.isHidden = true

        self.imageView.setImage(from: schedule.item.poster,
                                placeholder: .imgPlaceholder) { result in
            switch result {
            case .failure:
                self.releaseTitleLabel.superview?.isHidden = false
                self.releaseTitleLabel.superview?.fadeTransition()
            default:
                self.releaseTitleLabel.superview?.isHidden = true
            }
        }
        self.renderIndicator(schedule)
    }

    private func renderIndicator(_ schedule: ScheduleItem) {
        let hasUpdates = schedule.newEpisode != nil
        self.releaseIndicatorView.forEach { $0.isHidden = !hasUpdates }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
