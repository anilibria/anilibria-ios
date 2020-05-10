import UIKit

// MARK: - View Controller

final class SeriesContainerViewController: BaseViewController {
    @IBOutlet var pagerView: PagerView!

    private lazy var titleControl = UISegmentedControl(items: [
        L10n.Screen.Series.title,
        L10n.Screen.Comments.title
    ])
        .apply { [unowned self] in
        $0.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }

    var handler: SeriesContainerEventHandler!

    var pages: [UIViewController] = []

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTitleView()
        self.setupNavigationButtons()
        self.setupPager()
        self.handler.didLoad()
    }

    private func setupTitleView() {
        self.navigationItem.titleView = self.titleControl
    }

    private func setupNavigationButtons() {
        var item: BarButton!
        item = BarButton(image: #imageLiteral(resourceName: "icon_share"),
                         imageEdge: inset(8, 0, 10, 0)) { [weak self, weak item] in
                            self?.handler.share(sourceView: item?.customView)
        }
        self.navigationItem.setRightBarButtonItems([item], animated: false)
    }

    func setupPager() {
        self.pagerView.set(controllers: self.pages)
        self.pagerView.scrollTo(index: 0, direction: .forward, animated: false)

        self.updateState()
        self.pagerView.didIndexChanged { [weak self] _ in
            self?.updateState()
        }

        let gesture = self.navigationController?.view
            .gestureRecognizers?
            .first { $0 is UIScreenEdgePanGestureRecognizer } as? UIScreenEdgePanGestureRecognizer
        self.pagerView.require(gesture: gesture)
    }

    private func updateState() {
        if let index = self.pagerView.currentIndex {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.2
            fadeTextAnimation.type = .fade
            self.titleControl.layer.add(fadeTextAnimation, forKey: "titleView")
            self.titleControl.selectedSegmentIndex = index
        }
    }

    // MARK: - Actions

    @objc func valueChanged(_ sender: Any) {
        let index = self.titleControl.selectedSegmentIndex

        let direction: UIPageViewController.NavigationDirection
        direction = index == 1 ? .forward : .reverse

        self.pagerView.scrollTo(index: index, direction: direction, animated: true)
    }
}

extension SeriesContainerViewController: SeriesContainerViewBehavior {}
