import UIKit

public final class PseudoInteractiveDismissManager: NSObject, UIGestureRecognizerDelegate {
    private weak var scroll: UIScrollView?
    private weak var view: UIView?
    private var pan: UIPanGestureRecognizer!

    private var dismiss: ActionFunc?
    private let sensitivity: CGFloat = 200

    func attchTo(scroll: UIScrollView, dismiss: @escaping ActionFunc) {
        self.scroll = scroll
        self.scroll?.alwaysBounceVertical = true
        self.pan = self.scroll?.panGestureRecognizer
        self.pan.addTarget(self, action: #selector(self.pan(_:)))
        self.dismiss = dismiss
    }

    func attchTo(view: UIView, dismiss: @escaping ActionFunc) {
        self.view = view
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(self.animatingPan(_:)))
        self.pan.maximumNumberOfTouches = 1
        self.view?.addGestureRecognizer(self.pan)
        self.dismiss = dismiss
    }

    @objc private func pan(_ sender: UIPanGestureRecognizer) {
        guard self.scroll?.contentOffset.y ?? 0 <= 0 else { return }

        if sender.state == .ended {
            let velocity = sender.velocity(in: self.scroll).y
            if velocity > self.sensitivity {
                self.dismiss?()
            }
        }
    }

    @objc private func animatingPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view).y
        let velocity = sender.velocity(in: self.view).y

        switch sender.state {
        case .changed:
            if translation > 0 {
                self.view?.transform = CGAffineTransform(translationX: 0, y: translation / 2.5)
            }
        case .ended:
            if velocity > self.sensitivity {
                self.dismiss?()
            } else {
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 0,
                               options: .curveEaseInOut,
                               animations: {
                                   self.view?.transform = .identity
                               },
                               completion: nil)
            }
        default:
            return
        }
    }
}
