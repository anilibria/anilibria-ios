import UIKit

@IBDesignable
public class CircleView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = min(self.bounds.height, self.bounds.width) / 2
    }

    @IBInspectable public var borderThickness: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }

    @IBInspectable public var borderColor: UIColor? {
        get {
            return self.layer.borderColor != nil ? UIColor(cgColor: self.layer.borderColor!) : nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}

@IBDesignable
public class BorderedView: UIView {
    private var border = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

    open func setupNib() {
        self.border.lineDashPattern = [4, 0]
        self.border.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(self.border)
    }

    private func setupPath() {
        self.border.path = UIBezierPath(roundedRect: self.border.bounds,
                                        cornerRadius: self.cornerRadius - self.borderThickness / 2).cgPath
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.border.frame = CGRect(x: self.borderThickness / 2,
                                   y: self.borderThickness / 2,
                                   width: self.bounds.width - self.borderThickness,
                                   height: self.bounds.height - self.borderThickness)
        self.setupPath()
    }

    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            self.setupPath()
        }
    }

    @IBInspectable public var borderThickness: CGFloat {
        get {
            return self.border.lineWidth
        }
        set {
            self.border.lineWidth = newValue
        }
    }

    @IBInspectable public var borderColor: UIColor? {
        get {
            return self.border.strokeColor != nil ? UIColor(cgColor: self.border.strokeColor!) : nil
        }
        set {
            self.border.strokeColor = newValue?.cgColor
        }
    }

    @IBInspectable public var dashLength: Int {
        get {
            return self.border.lineDashPattern?.first?.intValue ?? 0
        }
        set {
            self.border.lineDashPattern = [NSNumber(value: newValue), NSNumber(value: dashSpace)]
        }
    }

    @IBInspectable public var dashSpace: Int {
        get {
            return self.border.lineDashPattern?.last?.intValue ?? 0
        }
        set {
            self.border.lineDashPattern = [NSNumber(value: dashLength), NSNumber(value: newValue)]
        }
    }
}
