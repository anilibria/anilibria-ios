import UIKit

extension UIView {
    static func fromNib() -> Self? {
        let nibView = Bundle.main.loadNibNamed(String(describing: self),
                                               owner: nil,
                                               options: nil)?.first
        let view = nibView >> self
        return view
    }
    
    func constraintEdgesToSuperview(_ edges: LayoutInsets = .init()) {
        guard let superview = self.superview else {
            assertionFailure("superview is required")
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            edges.top.map { topAnchor.constraint(equalTo: superview.topAnchor, constant: $0) },
            edges.bottom.map { superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: $0) },
            edges.left.map { leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: $0) },
            edges.right.map { superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: $0) }
        ].compactMap { $0 })
    }
    
    func fadeTransition(_ duration: Double = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade

        self.layer.add(transition, forKey: "transition")
    }
}

extension UIDevice {
    func set(orientation: UIInterfaceOrientation) {
        let value = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
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
    public var top: CGFloat?
    public var left: CGFloat?
    public var bottom: CGFloat?
    public var right: CGFloat?

    public init(top: CGFloat? = 0, left: CGFloat? = 0, bottom: CGFloat? = 0, right: CGFloat? = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}
