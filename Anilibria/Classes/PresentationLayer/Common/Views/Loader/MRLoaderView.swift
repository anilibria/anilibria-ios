import UIKit

public class MRLoaderView: LoadableView, Loader {
    private let animationView: UIImageView = UIImageView()

    @IBOutlet private var shadowView: ShadowView! {
        didSet {
            shadowView.shadowX = 0
            shadowView.shadowY = 10
            shadowView.shadowRadius = 10
            shadowView.shadowOpacity = 0.2
        }
    }

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
        containerView.smoothCorners(with: 16)
        containerView.addSubview(self.animationView)
        containerView.backgroundColor = UIColor(resource: .Surfaces.content)
        animationView.apply {
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
