import UIKit

final class DropDownPresentationController: UIPresentationController {
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(DropDownPresentationController.dimmingViewTapped(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()

    var targetFrame: CGRect = .zero
    var contentSize: Factory<CGSize>?

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        self.dimmingView.frame = containerView!.bounds
        presentedView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        presentedView?.transform = CGAffineTransform(translationX: 0, y: -20)
        containerView?.insertSubview(self.dimmingView, at: 0)
        let animations = {
            self.presentedView?.transform = CGAffineTransform.identity
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
            self.presentedView?.transform = CGAffineTransform(translationX: 0, y: -20)
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
        self.dimmingView.frame = containerView!.bounds
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return self.calculateFrame(parentSize: containerView!.bounds.size)
    }

    func calculateFrame(parentSize: CGSize) -> CGRect {
        let contentHeight: CGFloat = contentSize?().height ?? 0
        let width: CGFloat = parentSize.width
        return CGRect(x: 0,
                      y: self.targetFrame.maxY,
                      width: width,
                      height: contentHeight)
    }

    // MARK: Private

    @objc
    private func dimmingViewTapped(_ tap: UITapGestureRecognizer) {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
