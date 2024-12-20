import UIKit

public class CircleView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.smoothCorners(with: min(bounds.height, bounds.width) / 2)
    }

    public var borderThickness: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }

    public var borderColor: UIColor? {
        didSet {
            updateBorderColor()
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }

    private func updateBorderColor() {
        layer.borderColor = borderColor?.cgColor
    }
}

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

    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            self.setupPath()
        }
    }

    public var borderThickness: CGFloat {
        get {
            return self.border.lineWidth
        }
        set {
            self.border.lineWidth = newValue
        }
    }

    public var borderColor: UIColor? {
        didSet {
            updateBorderColor()
        }
    }

    public var dashLength: Int {
        get {
            return self.border.lineDashPattern?.first?.intValue ?? 0
        }
        set {
            self.border.lineDashPattern = [NSNumber(value: newValue), NSNumber(value: dashSpace)]
        }
    }

    public var dashSpace: Int {
        get {
            return self.border.lineDashPattern?.last?.intValue ?? 0
        }
        set {
            self.border.lineDashPattern = [NSNumber(value: dashLength), NSNumber(value: newValue)]
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }

    private func updateBorderColor() {
        border.strokeColor = borderColor?.cgColor
    }
}
