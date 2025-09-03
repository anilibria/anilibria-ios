import UIKit

final class BarButton: UIBarButtonItem {
    private var didTapAction: ActionFunc?
    private var button: RippleButton?
    private var normalImage: UIImage?
    private var activeImage: UIImage?

    override var tintColor: UIColor? {
        get {
            return self.button?.tintColor
        }
        set {
            self.button?.tintColor = newValue
        }
    }

    var active = false {
        didSet {
            if self.active == true {
                self.button?.setImage(self.activeImage, for: .normal)
            } else {
                self.button?.setImage(self.normalImage, for: .normal)
            }
        }
    }

    convenience init(type: UIButton.ButtonType = .system,
                     image: UIImage,
                     activeImage: UIImage? = nil,
                     tintColor: UIColor? = nil,
                     rippleColor: UIColor? = nil,
                     imageEdge: UIEdgeInsets = .zero,
                     action: ActionFunc?) {
        let tintColor = tintColor ?? .Tint.main
        let rippleColor = rippleColor ?? .Tint.main

        let button = BarRippleButton(type: type)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentSize = CGSize(width: 30, height: 44)
        button.tintColor = tintColor
        button.setImage(image, for: .normal)
        button.rippleColor = rippleColor
        button.imageEdgeInsets = imageEdge
        button.imageView?.contentMode = .scaleAspectFit
        self.init(customView: button)
        self.normalImage = image
        self.activeImage = activeImage
        self.didTapAction = action
        self.button = button
        button.addTarget(self, action: #selector(self.didTap), for: .touchUpInside)
    }

    func set(text: String) {
        self.button?.setTitle(text, for: .normal)
    }

    @objc func didTap() {
        self.didTapAction?()
    }
}

public class BarRippleButton: RippleButton {
    var contentSize: CGSize = UIView.layoutFittingCompressedSize

    public override var intrinsicContentSize: CGSize {
        contentSize
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.layoutMargins = .init(top: 7, left: 0, bottom: 7, right: 0)
        let container = BorderedView()
        container.cornerRadius = 4
        container.isUserInteractionEnabled = false
        container.clipsToBounds = true
        addSubview(container)
        container.constraintEdgesToSuperview(.init(
            top: .margins(0),
            left: .margins(0),
            bottom: .margins(0),
            right: .margins(0)
        ))
        rippleContainerView = container
    }
}
