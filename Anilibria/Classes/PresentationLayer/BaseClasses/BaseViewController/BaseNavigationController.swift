import UIKit

open class BaseNavigationController: UINavigationController {
    open var isInteractivePopEnabled: Bool = true

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.viewControllers.last?.preferredStatusBarStyle ?? .default
    }

    // MARK: - Orientation

    open override var shouldAutorotate: Bool {
        return false
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count > 1 && self.isInteractivePopEnabled {
            return true
        }
        return false
    }
}
