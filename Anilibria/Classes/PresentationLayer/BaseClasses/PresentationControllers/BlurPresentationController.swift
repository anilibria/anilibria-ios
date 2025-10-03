import UIKit

protocol Transformation {
    func beforePresent(_ view: UIView?)
    func present(_ view: UIView?)
    func beforeDissmiss(_ view: UIView?)
    func dissmiss(_ view: UIView?)
}

final class BlurPresentationController: UIPresentationController {
    public var isBlured: Bool = true
    private lazy var dimmingView: UIView = {
        let color = UIColor.black
        if self.isBlured {
            let view = FractionVisualEffectView(effect: UIBlurEffect(style: .dark),
                                                fraction: 0.3)

            view.backgroundColor = color.withAlphaComponent(0.4)
            return view
        }
        let view = UIView()
        view.backgroundColor = color.withAlphaComponent(0.6)
        return view

    }()

    public var transformation: Transformation = ScaleTransformation()

    private let wrapView = UIView()

    override var presentedView: UIView? {
        return wrapView
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        guard let view = super.presentedView else {
            return
        }
        wrapView.frame = view.frame
        wrapView.addSubview(view)
        if let size = containerView?.bounds.size {
            self.updateDimmingFrame(size)
        }
        self.containerView?.insertSubview(self.dimmingView, at: 0)
        self.dimmingView.alpha = 0

        self.transformation.beforePresent(view)
        let animations = {
            self.dimmingView.alpha = 1
            self.transformation.present(view)
        }

        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }

    override func dismissalTransitionWillBegin() {
        let animations = {
            self.transformation.dissmiss(self.presentedView)
            self.dimmingView.alpha = 0
        }

        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }

    override var adaptivePresentationStyle: UIModalPresentationStyle {
        return .none
    }

    override var shouldPresentInFullscreen: Bool {
        return true
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return self.calculateFrame(parentSize: parentSize).size
    }

    override func containerViewWillLayoutSubviews() {
        self.updateDimmingFrame(containerView!.bounds.size)
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return self.calculateFrame(parentSize: containerView!.bounds.size)
    }

    private func calculateFrame(parentSize: CGSize) -> CGRect {
        return CGRect(origin: .zero, size: parentSize)
    }

    private func updateDimmingFrame(_ parentSize: CGSize) {
        self.dimmingView.frame = CGRect(origin: .zero,
                                        size: parentSize)
    }
}

public final class FractionVisualEffectView: UIVisualEffectView {
    private var animator: UIViewPropertyAnimator!

    public init(effect: UIVisualEffect?, fraction: CGFloat) {
        super.init(effect: nil)
        self.animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            self?.effect = effect
        }
        self.animator.fractionComplete = fraction
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.animator.stopAnimation(true)
    }
}

public class ScaleTransformation: Transformation {
    private let transform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)

    func beforePresent(_ view: UIView?) {
        view?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view?.transform = self.transform
    }

    func present(_ view: UIView?) {
        view?.transform = CGAffineTransform.identity
    }

    func beforeDissmiss(_ view: UIView?) {}

    func dissmiss(_ view: UIView?) {
        view?.transform = self.transform
    }
}

public class MoveUpTransformation: Transformation {
    private let transform: CGAffineTransform = CGAffineTransform(translationX: 0,
                                                                 y: UIScreen.main.bounds.height)

    func beforePresent(_ view: UIView?) {
        view?.transform = self.transform
    }

    func present(_ view: UIView?) {
        view?.transform = .identity
    }

    func beforeDissmiss(_ view: UIView?) {}

    func dissmiss(_ view: UIView?) {
        view?.transform = self.transform
    }
}
