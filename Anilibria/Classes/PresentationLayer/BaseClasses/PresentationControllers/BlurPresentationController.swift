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

    override func presentationTransitionWillBegin() {
        guard let containerView, let view = super.presentedView else {
            return
        }
        wrapView.addSubview(view)
        wrapView.frame = containerView.bounds
        updateDimmingFrame()
        containerView.insertSubview(self.dimmingView, at: 0)
        dimmingView.alpha = 0

        transformation.beforePresent(view)
        let animations = { [weak self] in
            self?.dimmingView.alpha = 1
            self?.transformation.present(view)
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
        return parentSize
    }

    override func containerViewWillLayoutSubviews() {
        self.updateDimmingFrame()
        self.wrapView.frame = self.frameOfPresentedViewInContainerView
        super.presentedView?.frame = wrapView.bounds
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView?.bounds ?? .zero
    }

    private func updateDimmingFrame() {
        if let bounds = containerView?.bounds {
            dimmingView.frame = bounds
        }
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
