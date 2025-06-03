import UIKit

public final class SeriesHeaderView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var playIconView: UIView!
    @IBOutlet private var blockView: UIView!
    @IBOutlet private var blockTitleLabel: UILabel!
    @IBOutlet private var shimmerView: ShimmerView! {
        didSet {
            shimmerView.backgroundColor = UIColor(resource: .Tint.shimmer)
            shimmerView.shimmerColor = UIColor(resource: .Surfaces.base)
            shimmerView.run()
        }
    }

    private var handler: ActionFunc?

    func setPlay(handler: ActionFunc?) {
        self.handler = handler
    }

    func configure(_ series: Series) {
        shimmerView.isHidden = true
        shimmerView.stop()
        self.imageView.setImage(
            from: series.poster,
            placeholder: UIImage(resource: .imgPlaceholder)
        )

        self.blockView.isHidden = !series.isBlocked
        self.blockTitleLabel.text = L10n.Common.contentBlocked
    }

    func setPlayVisible(value: Bool) {
        self.playIconView.isHidden = !value
        self.isUserInteractionEnabled = value
    }

    @IBAction func playAction(_ sender: Any) {
        self.handler?()
    }
}
