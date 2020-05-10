import UIKit

public final class LinkView: UIView {
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    private var handler: Action<LinkData>?

    private var data: LinkData?

    func setTap(handler: Action<LinkData>?) {
        self.handler = handler
    }

    func configure(_ data: LinkData) {
        self.data = data
        self.titleLabel.text = data.title
        self.iconImageView.templateImage = data.linkType.icon
    }

    @IBAction func tapAction(_ sender: Any) {
        if let value = data {
            self.handler?(value)
        }
    }
}
