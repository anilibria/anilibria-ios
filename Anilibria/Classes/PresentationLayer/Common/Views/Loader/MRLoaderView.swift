import Lottie
import UIKit

public class MRLoaderView: LoadableView, Loader {
    private let animationView: LottieAnimationView = LottieAnimationView()
    private let animation: LottieAnimation? = LottieAnimation.named("nyan_cat")
    @IBOutlet var containerView: UIView! {
        didSet {
            self.configure()
        }
    }

    public override func setupNib() {
        super.setupNib()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.enterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    private func configure() {
        self.containerView.addSubview(self.animationView)
        self.animationView.apply {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
            $0.animation = animation
            $0.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                $0.topAnchor.constraint(equalTo: containerView.topAnchor)
            ]

            NSLayoutConstraint.activate(constraints)
        }
    }

    @objc private func enterForeground() {
        self.start()
    }

    public func start() {
        self.animationView.play()
    }

    public func stop() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
