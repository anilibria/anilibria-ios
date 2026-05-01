import UIKit

public final class StubView: UIView {
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var stackView: UIStackView!

    @IBOutlet private var iconView: UIImageView! {
        didSet {
            updateImage()
        }
    }

    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            self.titleLabel?.text = self.title
        }
    }

    @IBOutlet private var messageLabel: UILabel! {
        didSet {
            self.messageLabel?.text = self.message
        }
    }

    private var image: UIImage?
    private var color: UIColor = .clear

    public var isHorizontal: Bool = false {
        didSet {
            if isHorizontal {
                rootStackView.alignment = .leading
                stackView.axis = .horizontal
                titleLabel.textAlignment = .left
                messageLabel.textAlignment = .left
            } else {
                rootStackView.alignment = .center
                stackView.axis = .vertical
                titleLabel.textAlignment = .center
                messageLabel.textAlignment = .center
            }
        }
    }

    public var title: String = "" {
        didSet {
            self.titleLabel?.text = self.title
        }
    }

    public var message: String = "" {
        didSet {
            self.messageLabel?.text = self.message
        }
    }

    public var messageLinesLimit: Int = 0 {
        didSet {
            self.messageLabel?.numberOfLines = messageLinesLimit
        }
    }

    func set(image: UIImage?, color: UIColor) {
        self.image = image
        self.color = color
        updateImage()
    }

    private func updateImage() {
        self.iconView.image = image?.withRenderingMode(.alwaysTemplate)
        self.iconView.tintColor = self.color
    }
}
