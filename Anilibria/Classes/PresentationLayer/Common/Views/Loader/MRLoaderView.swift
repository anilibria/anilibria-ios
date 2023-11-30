import UIKit

public class MRLoaderView: LoadableView, Loader {
    private let animationView: UIImageView = UIImageView()
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
            $0.setImage(from: Bundle.main.url(forResource: "nyan_cat", withExtension: ".gif"))
            $0.contentMode = .scaleAspectFit
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

    public func start() {}

    public func stop() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
