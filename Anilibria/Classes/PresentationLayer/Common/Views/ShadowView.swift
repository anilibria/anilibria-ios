import UIKit

public final class ShadowView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !layer.shouldRasterize {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        }
    }

    public var shadowColor: UIColor? {
        didSet { updateShadowColor() }
    }

    public var shadowX: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset = CGSize(width: newValue,
                                        height: layer.shadowOffset.height)
        }
    }

    public var shadowY: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset = CGSize(width: layer.shadowOffset.width,
                                        height: newValue)
        }
    }

    public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        shadowX = 0
        shadowY = 5
        shadowRadius = 8
        shadowOpacity = 0.15
        shadowColor = .black
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateShadowColor()
    }

    private func updateShadowColor() {
        layer.shadowColor = shadowColor?.cgColor
    }
}
