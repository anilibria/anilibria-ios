import UIKit

public protocol ViewTransition {
    var animator: Animator { get }

    func prepareForDissmiss(_ view: UIView)
    func animateDissmiss(_ view: UIView)

    func prepareForShow(_ view: UIView)
    func animateShow(_ view: UIView)
}

public enum Animator {
    case normal(duration: TimeInterval, curve: UIView.AnimationCurve)
    case spring(duration: TimeInterval, dumping: CGFloat, velocity: CGFloat, curve: UIView.AnimationCurve)

    var duration: TimeInterval {
        switch self {
        case let .normal(duration, _), let .spring(duration, _, _, _):
            return duration
        }
    }

    func run(animation: @escaping ActionFunc, completion: ActionFunc? = nil) {
        switch self {
        case let .normal(duration, curve):
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: self.getOptions(from: curve),
                           animations: animation,
                           completion: { _ in completion?() })
        case let .spring(duration, dumping, velocity, curve):
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: dumping,
                           initialSpringVelocity: velocity,
                           options: self.getOptions(from: curve),
                           animations: animation,
                           completion: { _ in completion?() })
        }
    }

    private func getOptions(from curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        switch curve {
        case .linear:
            return .curveLinear
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        default:
            fatalError()
        }
    }
}

public struct FadeViewTransition: ViewTransition {
    public var animator: Animator {
        return .normal(duration: 0.5, curve: .easeInOut)
    }

    public func prepareForDissmiss(_ view: UIView) {}

    public func animateDissmiss(_ view: UIView) {
        view.alpha = 0
    }

    public func prepareForShow(_ view: UIView) {
        view.alpha = 0
    }

    public func animateShow(_ view: UIView) {
        view.alpha = 1
    }
}

public struct PushViewTransition: ViewTransition {
    public var animator: Animator {
        return .spring(duration: 0.5, dumping: 1, velocity: 0, curve: .easeInOut)
    }

    public func prepareForDissmiss(_ view: UIView) {}

    public func animateDissmiss(_ view: UIView) {
        let width: CGFloat = -view.bounds.width * 0.3
        view.transform = CGAffineTransform(translationX: width, y: 0)
    }

    public func prepareForShow(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
    }

    public func animateShow(_ view: UIView) {
        view.transform = .identity
    }
}

public struct FallViewTransition: ViewTransition {
    public var animator: Animator {
        return .spring(duration: 0.5, dumping: 0.7, velocity: 0, curve: .easeInOut)
    }

    public func prepareForDissmiss(_ view: UIView) {}

    public func animateDissmiss(_ view: UIView) {
        view.transform = .init(translationX: 0, y: -view.bounds.height - 50)
    }

    public func prepareForShow(_ view: UIView) {
        view.transform = .init(translationX: 0, y: -view.bounds.height - 50)
    }

    public func animateShow(_ view: UIView) {
        view.transform = .identity
    }
}
