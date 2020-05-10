import Foundation
import UIKit

public protocol NibLoadableProtocol: NSObjectProtocol {
    var nibContainerView: UIView { get }
    var clearBackground: Bool { get }

    func loadNib() -> UIView?

    func setupNib()

    var nibName: String { get }
}

extension UIView {
    public var nibContainerView: UIView {
        return self
    }
}

extension NibLoadableProtocol {
    public var nibName: String {
        return String(describing: type(of: self))
    }

    public func loadNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }

    internal func setupView(_ view: UIView?, inContainer container: UIView) {
        if let view = view {
            if self.clearBackground {
                container.backgroundColor = .clear
            }
            container.addSubview(view)
            view.frame = container.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
}

open class LoadableView: UIView, NibLoadableProtocol {
    public private(set) var view: UIView!

    public var clearBackground: Bool {
        return true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

    open func setupNib() {
        self.view = loadNib()
        setupView(self.view, inContainer: nibContainerView)
    }
}

open class LoadableControl: UIControl, NibLoadableProtocol {
    public var clearBackground: Bool {
        return true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

    open func setupNib() {
        setupView(loadNib(), inContainer: nibContainerView)
    }
}
