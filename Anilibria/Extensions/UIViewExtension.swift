import UIKit

extension UIView {
    static func fromNib() -> Self? {
        let nibView = Bundle.main.loadNibNamed(String(describing: self),
                                               owner: nil,
                                               options: nil)?.first
        let view = nibView >> self
        return view
    }
    
    func pinToParent() {
        guard let parent = self.superview else {
            fatalError("no superview")
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            self.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            self.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            self.topAnchor.constraint(equalTo: parent.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
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
