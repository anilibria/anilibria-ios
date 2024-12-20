import Combine
import UIKit

public protocol ChaperoneRouter {
    func move()
}

public protocol StatusBarChangeable: AnyObject {
    var statusBarStyle: UIStatusBarStyle { get set }
}

public class ModalRouter: NSObject, ChaperoneRouter {
    fileprivate weak var target: UIViewController!
    fileprivate weak var parent: UIViewController?
    fileprivate var windowLevel: UIWindow.Level = .normal

    init(target: UIViewController, parent: UIViewController?) {
        self.target = target
        self.parent = parent
        if parent == nil {
            self.target.modalPresentationStyle = .fullScreen
        }
    }

    public func set(level: UIWindow.Level) -> Self {
        self.windowLevel = level
        return self
    }

    public func move() {
        if let vc = parent {
            self.presentModal(self.target, from: vc)
        } else {
            self.presentModal(self.target)
        }
    }

    private func presentModal(_ controller: UIViewController, from parent: UIViewController) {
        parent.present(controller, animated: true, completion: {})
    }

    private func presentModal(_ controller: UIViewController) {
        guard let current = UIApplication.getWindow() else { return }
        current.topControllerInHierarchy()?.present(controller, animated: true)
    }
}

public class PushRouter: ChaperoneRouter {
    let target: UIViewController
    let parent: UIViewController
    let drop: Drop

    public enum Drop {
        case none
        case last
        case all
        case custom(Int)
    }

    init(target: UIViewController, parent: UIViewController, drop: Drop = .none) {
        self.target = target
        self.parent = parent
        self.drop = drop
    }

    public func move() {
        if let nc = parent.navigationController {
            self.present(self.target, using: nc)
        }
    }

    private func present(_ controller: UIViewController, using ncontroller: UINavigationController) {
        if ncontroller.topViewController == controller {
            return
        }

        switch self.drop {
        case .last:
            let controllers = Array(ncontroller.viewControllers.dropLast()) + [controller]
            ncontroller.setViewControllers(controllers, animated: true)
        case .all:
            ncontroller.setViewControllers([controller], animated: true)
        case let .custom(count):
            let controllers = Array(ncontroller.viewControllers.dropLast(count)) + [controller]
            ncontroller.setViewControllers(controllers, animated: true)
        default:
            ncontroller.pushViewController(controller, animated: true)
        }
    }
}

public final class ShowWindowRouter: ChaperoneRouter {
    let target: UIViewController
    let window: UIWindow
    let transition: ViewTransition

    init(target: UIViewController, window: UIWindow, transition: ViewTransition = FadeViewTransition()) {
        self.target = target
        self.window = window
        self.transition = transition
    }

    public func move() {
        self.present(self.target, using: self.window)
    }

    private func present(_ controller: UIViewController, using window: UIWindow) {
        let windows = UIApplication.shared.windows.filter {
            $0 != window
        }
        for other in windows {
            self.transition.prepareForDissmiss(other)
            self.transition.animator
                .run(animation: {
                    self.transition.animateDissmiss(other)
                }, completion: {
                    other.isHidden = true
                    other.rootViewController?.dismiss(animated: false)
                })
        }
        if let old = window.rootViewController {
            old.dismiss(animated: false, completion: {
                old.view.removeFromSuperview()
            })
        }

        self.transition.prepareForShow(window)
        self.transition.animator.run(animation: {
            self.transition.animateShow(window)
        })

        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}

public protocol ChildNavigationContainer: UIViewController {
    var childContainerView: UIView? { get }
}

public class ShowChildRouter: ChaperoneRouter {
    let target: UIViewController
    let parent: UIViewController
    let container: UIView?

    init(target: UIViewController, parent: UIViewController) {
        self.target = target
        self.parent = parent
        self.container = (parent as? ChildNavigationContainer)?.childContainerView
    }

    public func move() {
        self.presentChild(self.target, from: self.parent, in: self.container)
    }

    private func presentChild(_ controller: UIViewController, from parent: UIViewController, in container: UIView?) {
        if let view = container ?? parent.view {
            let old = parent.children.first
            old?.view.removeFromSuperview()
            old?.removeFromParent()
            parent.addChild(controller)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(controller.view)
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            UIView.transition(with: view,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
}

public final class PresentRouter<T: UIPresentationController>: ModalRouter, UIViewControllerTransitioningDelegate {
    let presentation: T.Type
    let configure: ((T) -> Void)?

    init(target: UIViewController, from parent: UIViewController?, use presentation: T.Type, configure: ((T) -> Void)?) {
        self.presentation = presentation
        self.configure = configure
        super.init(target: target, parent: parent)

        self.target.modalTransitionStyle = .crossDissolve
        self.target.modalPresentationStyle = .custom
        self.target.modalPresentationCapturesStatusBarAppearance = true
        self.target.transitioningDelegate = self
        self.target.storeLink(self)
    }

    public func set(_ modalPresentationStyle: UIModalPresentationStyle) -> Self {
        self.target.modalPresentationStyle = modalPresentationStyle
        return self
    }

    public override func move() {
        super.move()
    }

    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        let value = presentation.init(presentedViewController: presented, presenting: presenting)
        self.configure?(value)
        return value
    }
}

// MARK: - Support classes

private class MRViewController: UIViewController {
    func close() {
        view.removeFromSuperview()
        removeFromParent()
    }
}

private extension UIViewController {
    func storeLink(_ item: Any?) {
        let holder = HolderHelper()
        holder.storedObject = item
        self.view.addLayoutGuide(holder)
    }
}

private final class HolderHelper: UILayoutGuide {
    var storedObject: Any?

    deinit {
        if let value = storedObject as? MRViewController {
            value.close()
        }
        storedObject = nil
    }
}

private extension UIWindow {

    func topControllerInHierarchy() -> UIViewController? {
        var topController = self.rootViewController

        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }

        guard let topViewController: UIViewController = topController else {
            return topController
        }

        if let tabBarController = topViewController as? UITabBarController {
            if let navController = tabBarController.selectedViewController as? UINavigationController {
                topController = navController.visibleViewController
            }
        } else if let topNavController = topViewController as? UINavigationController {
            topController = topNavController.visibleViewController
        }

        return topController
    }
}
