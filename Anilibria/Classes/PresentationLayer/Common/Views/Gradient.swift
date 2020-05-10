import UIKit

typealias GradientPoint = (x: CGPoint, y: CGPoint)

enum GradientType: String {
    case leftRight
    case rightLeft
    case topBottom
    case bottomTop
    case topLeftBottomRight
    case bottomRightTopLeft
    case topRightBottomLeft
    case bottomLeftTopRight

    func draw() -> GradientPoint {
        switch self {
        case .leftRight:
            return (x: CGPoint(x: 0, y: 0.5), y: CGPoint(x: 1, y: 0.5))
        case .rightLeft:
            return (x: CGPoint(x: 1, y: 0.5), y: CGPoint(x: 0, y: 0.5))
        case .topBottom:
            return (x: CGPoint(x: 0.5, y: 0), y: CGPoint(x: 0.5, y: 1))
        case .bottomTop:
            return (x: CGPoint(x: 0.5, y: 1), y: CGPoint(x: 0.5, y: 0))
        case .topLeftBottomRight:
            return (x: CGPoint(x: 0, y: 0), y: CGPoint(x: 1, y: 1))
        case .bottomRightTopLeft:
            return (x: CGPoint(x: 1, y: 1), y: CGPoint(x: 0, y: 0))
        case .topRightBottomLeft:
            return (x: CGPoint(x: 1, y: 0), y: CGPoint(x: 0, y: 1))
        case .bottomLeftTopRight:
            return (x: CGPoint(x: 0, y: 1), y: CGPoint(x: 1, y: 0))
        }
    }
}

class GradientLayer: CAGradientLayer {
    var gradient: GradientType? {
        didSet {
            let point = self.gradient?.draw()
            startPoint = point?.x ?? CGPoint.zero
            endPoint = point?.y ?? CGPoint.zero
        }
    }
}

protocol GradientViewProvider {
    associatedtype GradientViewType where GradientViewType: CAGradientLayer
}

extension GradientViewProvider where Self: UIView {
    var gradientLayer: GradientViewType {
        if let gr = layer as? GradientViewType {
            return gr
        }
        fatalError()
    }
}

extension UIView: GradientViewProvider {
    typealias GradientViewType = GradientLayer
}

class GradientView: UIView {
    public override class var layerClass: Swift.AnyClass {
        return GradientLayer.self
    }

    @IBInspectable
    var firstColor: UIColor? {
        didSet {
            self.updateColors()
        }
    }

    @IBInspectable
    var secondColor: UIColor? {
        didSet {
            self.updateColors()
        }
    }

    @IBInspectable
    var gradientTypeName: String = "" {
        didSet {
            self.gradientLayer.gradient = GradientType(rawValue: gradientTypeName)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.updateColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateColors()
    }

    private func updateColors() {
        if let first = self.firstColor, let second = self.secondColor {
            self.gradientLayer.colors = [first, second].compactMap { $0.cgColor }
        }
    }
}
