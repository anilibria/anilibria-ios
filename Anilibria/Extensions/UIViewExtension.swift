import UIKit

extension UIView {
    static func fromNib() -> Self? {
        let nibView = Bundle.main.loadNibNamed(String(describing: self),
                                               owner: nil,
                                               options: nil)?.first
        return nibView as? Self
    }
    
    func constraintEdgesToSuperview(_ edges: LayoutInsets = .init()) {
        guard let superview = self.superview else {
            assertionFailure("superview is required")
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            edges.top.map { topAnchor.constraint(equalTo: $0.getAnchorView(superview).topAnchor, constant: $0.value) },
            edges.bottom.map { $0.getAnchorView(superview).bottomAnchor.constraint(equalTo: bottomAnchor, constant: $0.value) },
            edges.left.map { leadingAnchor.constraint(equalTo: $0.getAnchorView(superview).leadingAnchor, constant: $0.value) },
            edges.right.map { $0.getAnchorView(superview).trailingAnchor.constraint(equalTo: trailingAnchor, constant: $0.value) }
        ].compactMap { $0 })
    }

    func fadeTransition(_ duration: Double = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade

        self.layer.add(transition, forKey: "transition")
    }
}

extension UIApplication {
	static var keyWindowSize: CGSize {
		guard let window = getWindow() else {
			return .zero
		}
		
		return window.frame.size
	}
}

public struct LayoutInsets {
    public var top: Value?
    public var left: Value?
    public var bottom: Value?
    public var right: Value?

    public enum Value: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
        case superview(CGFloat)
        case safeArea(CGFloat = 0)
        case margins(CGFloat = 0)
        case custom(source: any LayoutSource, value: CGFloat = 0)

        public init(floatLiteral value: Double) {
            self = .superview(CGFloat(value))
        }

        public init(integerLiteral value: Int) {
            self = .superview(CGFloat(value))
        }

        fileprivate func getAnchorView(_ view: UIView) -> any LayoutSource {
            switch self {
            case .superview: return view
            case .safeArea: return view.safeAreaLayoutGuide
            case .margins: return view.layoutMarginsGuide
            case .custom(let source, _): return source
            }
        }

        fileprivate var value: CGFloat {
            switch self {
            case .superview(let value),
                 .safeArea(let value),
                 .margins(let value),
                 .custom(_, let value):
                return value
            }
        }
    }

    public init(top: Value? = 0,
                left: Value? = 0,
                bottom: Value? = 0,
                right: Value? = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

public protocol LayoutSource: AnyObject {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: LayoutSource {}
extension UILayoutGuide: LayoutSource {}
