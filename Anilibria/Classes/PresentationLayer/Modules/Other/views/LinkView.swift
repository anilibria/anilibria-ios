import UIKit

public final class LinkView: UIView {
    @IBOutlet private var iconImageView: UIImageView!

    private var handler: Action<LinkData>?

    private var data: LinkData?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.smoothCorners(with: 5)
    }

    func setTap(handler: Action<LinkData>?) {
        self.handler = handler
    }

    func configure(_ data: LinkData) {
        self.data = data
        self.iconImageView.templateImage = data.linkType.icon
    }

    @IBAction func tapAction(_ sender: Any) {
        if let value = data {
            self.handler?(value)
        }
    }
}
