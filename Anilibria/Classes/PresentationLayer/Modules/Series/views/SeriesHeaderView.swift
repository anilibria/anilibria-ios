import UIKit

public final class SeriesHeaderView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var playIconView: UIView!

    private var handler: ActionFunc?

    func setPlay(handler: ActionFunc?) {
        self.handler = handler
    }

    func configure(_ series: Series) {
        self.imageView.setImage(from: series.poster,
                                placeholder: UIImage(resource: .imgPlaceholder))
    }

    func setPlayVisible(value: Bool) {
        self.playIconView.isHidden = !value
        self.isUserInteractionEnabled = value
    }

    @IBAction func playAction(_ sender: Any) {
        self.handler?()
    }
}
