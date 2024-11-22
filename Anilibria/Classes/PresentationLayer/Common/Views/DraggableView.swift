import UIKit

public protocol DraggableViewDelegate: AnyObject {
    func callPrimaryAction()
    func didStart()
    func didEnd(_ isOpen: Bool)
    func progressChanged(value: CGFloat)
}

public extension DraggableViewDelegate {
    func callPrimaryAction() {}
    func didStart() {}
    func didEnd(_ isOpen: Bool) {}
    func progressChanged(value: CGFloat) {}
}

open class DraggableView: UIView {
    private weak static var activeView: DraggableView?

    @IBOutlet public var contentView: UIView!

    public var swipeOffset: CGFloat = 0
    public var threshold: CGFloat = 0.6
    public var isDraggingEnabled = true
    public weak var delegate: DraggableViewDelegate?

    public private(set) var isOpen: Bool = false

    private var needsCallAction: Bool = false
    private var locationX: CGFloat!
    private var startX: CGFloat?
    private let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    private weak var scrollView: UIScrollView?

    private var progress: CGFloat = 0 {
        didSet {
            if oldValue != self.progress {
                delegate?.progressChanged(value: self.progress)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.constraintEdgesToSuperview(
            .init(left: .margins(0), right: .margins(0))
        )
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    open func setup() {
        isUserInteractionEnabled = true
        update(position: 0)
        panRecognizer.addTarget(self, action: #selector(self.panAction(gesture:)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)

        tapRecognizer.addTarget(self, action: #selector(self.tapAction(gesture:)))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }

    deinit {
        scrollView?.panGestureRecognizer.removeTarget(self, action: nil)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        var view: UIView = self
        while let superview = view.superview {
            view = superview

            if let collectionView = view as? UIScrollView {
                self.scrollView = collectionView

                scrollView?.panGestureRecognizer.removeTarget(self, action: nil)
                scrollView?.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPan(gesture:)))
                return
            }
        }
    }

    public func open() {
        progress = 1
        isOpen = true
        delegate?.didEnd(self.isOpen)
        if DraggableView.activeView != self {
            DraggableView.activeView?.close(true)
            DraggableView.activeView = self
        }

        update(position: swipeOffset)
        apply(animation: true, action: {
            self.layoutIfNeeded()
        })
    }

    public func close(_ animation: Bool = false) {
        cancelPan()
        isOpen = false
        delegate?.didEnd(isOpen)
        if DraggableView.activeView == self {
            DraggableView.activeView = nil
        }
        update(position: 0)
        apply(animation: animation) {
            self.layoutIfNeeded()
        } completion: {
            self.progress = 0
        }
    }

    public func toggle() {
        if let startLocationX = startX {
            if locationX - startLocationX < 0 {
                open()
            } else {
                close(true)
            }
        } else {
            close(true)
        }
    }

    private func apply(animation: Bool,
                       action: @escaping () -> Void,
                       completion: (() -> Void)? = nil) {
        if animation {
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseInOut,
                           animations: action,
                           completion: { _ in  completion?() })
        } else {
            action()
            completion?()
        }
    }

    @objc private func handleScrollPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            DraggableView.activeView?.close(true)
        }
    }

    @objc private func tapAction(gesture: UIPanGestureRecognizer) {
        DraggableView.activeView?.close(true)
    }

    @objc private func panAction(gesture: UIPanGestureRecognizer) {
        var translation = ceil(gesture.translation(in: nil).x)

        if isOpen {
            translation -= swipeOffset
        }

        if gesture.state == .began {
            if DraggableView.activeView != self &&
                DraggableView.activeView != nil &&
                DraggableView.activeView?.isOpen == false {
                return
            }

            if DraggableView.activeView != self {
                DraggableView.activeView?.close(true)
                DraggableView.activeView = self
            }

            delegate?.didStart()
            startX = ceil(gesture.location(in: nil).x)
            return
        }

        if DraggableView.activeView != self { return }

        switch gesture.state {
        case .changed:
            if -translation > swipeOffset {
                update(position: -translation)
                progress = 1
            } else if translation > 0 {
                update(position: 0)
                progress = 0
            } else {
                update(position: -translation)
                progress = abs(translation / swipeOffset)
            }
            if translation < 0 {
                setNeeedsCall(abs(translation / self.bounds.width) >= threshold)
            }
        case .ended, .failed, .cancelled:
            locationX = ceil(gesture.location(in: nil).x)
            if needsCallAction {
                needsCallAction = false
                delegate?.callPrimaryAction()
                close(true)
            } else {
                toggle()
            }
        default:
            break
        }
    }

    private func cancelPan() {
        panRecognizer.isEnabled = false
        panRecognizer.isEnabled = true
    }

    private func setNeeedsCall(_ value: Bool) {
        if needsCallAction != value {
            needsCallAction = value
            FeedbackGenerator.default.produce()
        }
    }

    private func update(position: CGFloat) {
        layoutMargins.left = -position
        layoutMargins.right = position
    }
}

extension DraggableView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !isDraggingEnabled { return false }

        if gestureRecognizer == tapRecognizer {
            return DraggableView.activeView != nil
        }

        if gestureRecognizer == panRecognizer {
            let view = panRecognizer.view
            let translation = panRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }

        return true
    }
}
