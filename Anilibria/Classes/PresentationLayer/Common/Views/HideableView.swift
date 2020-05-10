import UIKit

public final class HideableView: UIView {
    @IBOutlet var scrollView: UIScrollView! {
        didSet {
            self.alpha = 0
            self.subscribeOffset()
        }
    }

    private var tokenBag: Any?

    private var spaceFactory: () -> CGFloat = {
        0
    }

    public func setSpace(_ factory: @escaping () -> CGFloat) {
        self.spaceFactory = factory
    }

    private func subscribeOffset() {
        self.tokenBag = self.scrollView.observe(\UIScrollView.contentOffset) { [weak self] _, _ in
            guard let this = self else { return }
            let freeSpace = this.spaceFactory()
            this.separator(show: this.scrollView.contentOffset.y > freeSpace)
        }
    }

    private func separator(show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = show ? 1 : 0
        }
    }
}
