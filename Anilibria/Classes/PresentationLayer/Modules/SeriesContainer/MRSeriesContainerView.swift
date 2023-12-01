import UIKit

// MARK: - View Controller

final class SeriesContainerViewController: BaseViewController {
    @IBOutlet var pagerView: PagerView!

    private lazy var titleControl = UISegmentedControl(items: [
        L10n.Screen.Series.title,
        L10n.Screen.Comments.title
    ]).apply { [unowned self] in
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
    
    override func setupStrings() {
        super.setupStrings()
        titleControl.setTitle(L10n.Screen.Series.title, forSegmentAt: 0)
        titleControl.setTitle(L10n.Screen.Comments.title, forSegmentAt: 1)
    }

    private func setupNavigationButtons() {
        var item: BarButton!
        item = BarButton(image: UIImage(resource: .iconShare),
                         imageEdge: inset(8, 0, 10, 0)) { [weak self, weak item] in
                            self?.handler.share(sourceView: item?.customView)
        }
        self.navigationItem.setRightBarButtonItems([item], animated: false)
    }

    func setupPager() {
        self.pagerView.delegate = self
        self.pagerView.scrollTo(index: 0, animated: false)

        self.updateState()
        self.pagerView.didIndexChanged { [weak self] _ in
            self?.updateState()
        }
    }

    private func updateState() {
        if self.pagerView.currentIndex >= 0 {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.2
            fadeTextAnimation.type = .fade
            self.titleControl.layer.add(fadeTextAnimation, forKey: "titleView")
            self.titleControl.selectedSegmentIndex = pagerView.currentIndex
        }
    }

    // MARK: - Actions

    @objc func valueChanged(_ sender: Any) {
        let index = self.titleControl.selectedSegmentIndex
        self.pagerView.scrollTo(index: index, animated: true)
    }
}

extension SeriesContainerViewController: PagerViewDelegate {
    func numberOfPages(for pagerView: PagerView) -> Int {
        pages.count
    }

    func pagerView(_ pagerView: PagerView, pageFor index: Int) -> UIViewController? {
        pages[safe: index]
    }
}

extension SeriesContainerViewController: SeriesContainerViewBehavior {}
