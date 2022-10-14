import UIKit

public protocol DraggableViewDelegate: AnyObject {
    func didStart()
    func didEnd(_ isOpen: Bool)
    func progressChanged(value: CGFloat)
}

public class DraggableView: UIView {
    fileprivate weak static var openedView: DraggableView?

    @IBInspectable public var shiftLenght: CGFloat = 0

    public var isDraggingEnabled = true
    weak var delegate: DraggableViewDelegate?

    private var locationX: CGFloat!
    private var startX: CGFloat?
    private var originalLocation: CGPoint!
    private(set) var isOpen: Bool = false
    fileprivate var scrolling: Bool = false

    private var progress: CGFloat = 0 {
        didSet {
            if oldValue != self.progress {
                self.delegate?.progressChanged(value: self.progress)
            }
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }

    // MARK: - public

    public func open() {
        self.progress = 1
        self.isOpen = true
        self.delegate?.didEnd(self.isOpen)
        if DraggableView.openedView != self {
            DraggableView.openedView?.close(true)
            DraggableView.openedView = self
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                           self.transform = CGAffineTransform(translationX: -self.shiftLenght, y: 0)
                       },
                       completion: nil)
    }

    public func close(_ animation: Bool = false) {
        if self.isOpen == false {
            return
        }
        self.progress = 0
        self.isOpen = false
        self.delegate?.didEnd(self.isOpen)
        if animation {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                               self.transform = CGAffineTransform(translationX: 0, y: 0)
                           },
                           completion: nil)
        } else {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }

    public func toggle() {
        if let startLocationX = startX {
            if self.locationX - startLocationX < 0 {
                self.open()
            } else {
                self.close(true)
            }
        } else {
            self.close(true)
        }
    }

    // MARK: - Animate

    private func setup() {
        if self.originalLocation == nil && self.isDraggingEnabled {
            self.originalLocation = CGPoint(x: self.center.x, y: self.center.y)
            self.transform = CGAffineTransform(translationX: 0, y: 0)
            self.setupGestureRecornizer()
        }
    }

    private func setupGestureRecornizer() {
        let p = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(gesture:)))
        p.maximumNumberOfTouches = 1
        p.delegate = self
        self.addGestureRecognizer(p)
    }

    @objc func panAction(gesture: UIPanGestureRecognizer) {
        if self.scrolling { return }
        let t = gesture.translation(in: nil)
        var translation = ceil(t.x)

        if self.isOpen {
            translation -= self.shiftLenght
        }

        switch gesture.state {
        case .began:
            self.delegate?.didStart()
            self.startX = ceil(gesture.location(in: nil).x)
        case .ended:
            self.locationX = ceil(gesture.location(in: nil).x)
            self.toggle()
        default:
            if -translation > self.shiftLenght {
                self.transform = CGAffineTransform(translationX: -self.shiftLenght, y: 0)
                self.progress = 1
            } else if translation > 0 {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
                self.progress = 0
            } else {
                self.transform = CGAffineTransform(translationX: translation, y: 0)
                self.progress = abs(translation / self.shiftLenght)
            }
        }
    }
}

extension DraggableView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let translation = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: nil) {
            self.scrolling = false
            if abs(translation.x) < abs(translation.y) {
                self.scrolling = true
                DraggableView.openedView?.close(true)
                return true
            } else if translation.x < 0 {
                return false
            } else {
                if self.progress == 0 {
                    gestureRecognizer.isEnabled = false
                    gestureRecognizer.isEnabled = true
                    DraggableView.openedView?.close(true)
                }
                return self.progress == 0
            }
        }
        return false
    }

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
