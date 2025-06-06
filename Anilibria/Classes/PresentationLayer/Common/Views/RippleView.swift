import UIKit

public class RippleManager {
    public var isEnabled: Bool = true
    public var rippleColor: UIColor = .Tint.main
    public var rippleAlpha: CGFloat = 0.1
    public var mask: UIImage? {
        didSet {
            if self.mask != oldValue {
                self.setupMask()
            }
        }
    }

    private weak var rippleContainer: UIView!
    private var view: UIView!
    private var state: State = .ready
    private var rippleBounds: CGRect {
        return self.rippleContainer.bounds
    }

    init() {}

    init(attatch: UIView) {
        self.setup(attatch)
    }

    public func attach(to view: UIView) {
        self.setup(view)
    }

    private func setup(_ view: UIView) {
        self.rippleContainer = view
        self.setupMask()
    }

    public func clear() {
        self.view?.removeFromSuperview()
        self.view = nil
    }

    open func touchesBegan(_ touches: Set<UITouch>) {
        self.touchesBegan {
            touches.first?.location(in: $0)
        }
    }

    open func touchesBegan(_ touchPointFactory: @escaping (UIView) -> CGPoint?) {
        if self.state != .ready || self.isEnabled == false {
            return
        }
        self.state = .working
        self.view = UIView(frame: self.rippleBounds)
        self.view.isUserInteractionEnabled = false
        self.view.clipsToBounds = true
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        circle.isUserInteractionEnabled = false
        if let point = touchPointFactory(rippleContainer) {
            circle.center = point
        }
        circle.layer.cornerRadius = 2
        circle.alpha = self.rippleAlpha
        circle.backgroundColor = rippleColor
        let back = UIView(frame: view.bounds)
        back.alpha = 0
        back.backgroundColor = rippleColor

        view.addSubview(back)
        view.addSubview(circle)
        UIView.animate(withDuration: 0.2) {
            back.alpha = self.rippleAlpha
        }
        UIView.animate(withDuration: 2) {
            circle.transform = CGAffineTransform(scaleX: 1000, y: 1000)
        }

        rippleContainer.addSubview(view)
    }

    open func touchesEnded() {
        if self.state == .working {
            self.state = .ending
            self.hide()
        }
    }

    public func layout() {
        if let view = self.rippleContainer.mask {
            view.frame = self.rippleContainer.bounds
        }
        self.view?.frame = self.rippleBounds
        self.view?.layer.sublayers?.first?.frame = self.rippleBounds
    }

    private func hide() {
        if let view = self.view {
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
                self.view = nil
                self.state = .ready
            })
        }
    }

    private func setupMask() {
        if self.rippleContainer == nil {
            return
        }

        if self.mask != nil {
            let maskView = UIImageView(image: mask)
            maskView.frame = self.rippleContainer.bounds
            self.rippleContainer.mask = maskView
        } else {
            self.rippleContainer.mask = nil
        }
    }

    private enum State {
        case ready
        case working
        case ending
    }
}

open class RippleViewCell: UICollectionViewCell {
    public lazy var rippleManager: RippleManager = { [unowned self] in
        RippleManager(attatch: self)
    }()

    @IBOutlet var rippleContainerView: UIView! {
        didSet {
            self.rippleManager.attach(to: self.rippleContainerView)
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        rippleManager.rippleColor = .Tint.main
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.rippleManager.clear()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.rippleManager.touchesBegan(touches)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.rippleManager.touchesEnded()
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.rippleManager.touchesEnded()
    }
}

public class RippleButton: UIButton {
    private lazy var rippleManager: RippleManager = { [unowned self] in
        RippleManager(attatch: self)
    }()

    @IBOutlet var rippleContainerView: UIView! {
        didSet {
            self.rippleManager.attach(to: self.rippleContainerView)
        }
    }

    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    public var borderThickness: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable public var borderColor: UIColor? {
        get {
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    public var rippleColor: UIColor {
        get {
            return self.rippleManager.rippleColor
        }
        set {
            self.rippleManager.rippleColor = newValue
        }
    }

    @IBInspectable public var enabledColor: UIColor? {
        didSet {
            self.updateColor()
        }
    }

    @IBInspectable public var disabledColor: UIColor? {
        didSet {
            self.updateColor()
        }
    }

    /// increase touch area for control in all directions
    /// default: 0
    @IBInspectable var tapAreaMargin: CGFloat = 0

    public override var isEnabled: Bool {
        didSet {
            self.updateColor()
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.rippleManager.touchesBegan(touches)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.rippleManager.touchesEnded()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.rippleManager.touchesEnded()
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = self.bounds.insetBy(dx: -tapAreaMargin, dy: -tapAreaMargin)
        return area.contains(point)
    }

    private func updateColor() {
        if self.enabledColor != nil || self.disabledColor != nil {
            self.backgroundColor = self.isEnabled ? self.enabledColor : self.disabledColor
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.rippleManager.layout()
    }
}
