import UIKit

public final class ShadowView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !layer.shouldRasterize {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBInspectable
    public var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }

    @IBInspectable
    public var shadowX: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset = CGSize(width: newValue,
                                        height: layer.shadowOffset.height)
        }
    }

    @IBInspectable
    public var shadowY: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset = CGSize(width: layer.shadowOffset.width,
                                        height: newValue)
        }
    }

    @IBInspectable
    public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
}
