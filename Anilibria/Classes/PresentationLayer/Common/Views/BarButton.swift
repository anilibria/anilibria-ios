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
                     size: CGSize = .init(width: 30, height: 30),
                     tintColor: UIColor? = nil,
                     rippleColor: UIColor? = nil,
                     imageEdge: UIEdgeInsets = .zero,
                     action: ActionFunc?) {
        let tintColor = tintColor ?? UIColor(resource: .Tint.main)
        let rippleColor = rippleColor ?? UIColor(resource: .Tint.main)

        let button = RippleButton(type: type)
        button.frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 44))
        button.tintColor = tintColor
        let container = BorderedView(frame: CGRect(origin: .zero, size: size))
        container.cornerRadius = 4
        container.isUserInteractionEnabled = false
        container.clipsToBounds = true
        button.setImage(image, for: .normal)
        button.addSubview(container)
        let buttonSize = button.frame.size
        container.center = CGPoint(x: buttonSize.width / 2,
                                   y: buttonSize.height / 2)
        button.rippleContainerView = container
        button.rippleColor = rippleColor
        button.imageEdgeInsets = imageEdge
        self.init(customView: button)
        self.normalImage = image
        self.activeImage = activeImage
        self.didTapAction = action
        self.button = button
        button.addTarget(self, action: #selector(self.didTap), for: .touchUpInside)
    }

    convenience init(text: String,
                     font: UIFont = UIFont.systemFont(ofSize: 15, weight: .bold),
                     textColor: UIColor? = nil,
                     action: ActionFunc?) {
        let button = BarRippleButton(frame: .init(x: 0,
                                                  y: 0,
                                                  width: 1,
                                                  height: 44))

        button.titleLabel?.font = font
        button.rippleColor = UIColor(resource: .Tint.main)
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor ?? UIColor(resource: .Text.main), for: .normal)
        self.init(customView: button)
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
    let ripple: UIView = UIView(frame: .zero)
    private var size: CGSize = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        rippleContainerView = ripple
        self.ripple.clipsToBounds = true
        self.ripple.layer.cornerRadius = 11
        self.ripple.layer.zPosition = -100
        self.ripple.isUserInteractionEnabled = false
        self.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        self.addSubview(self.ripple)
        self.sizeToFit()
        self.size = frame.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        return self.size
    }
}
