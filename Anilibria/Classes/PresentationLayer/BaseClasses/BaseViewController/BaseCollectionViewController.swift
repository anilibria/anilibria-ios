import Foundation
import IGListKit

class BaseCollectionViewController: BaseViewController, ListAdapterDataSource {
    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!
    var items: [ListDiffable] = []

    private weak var refreshActivity: ActivityDisposable?

    // MARK: - Properties

    public private(set) var refreshControl: RefreshIndicator?

    var defaultBottomInset: CGFloat = 40

    public lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    public var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return self.adapter.scrollViewDelegate
        }
        set {
            self.adapter.scrollViewDelegate = newValue
        }
    }

    private lazy var manager: AdapterManager = { [unowned self] in
        AdapterManager(items: self.adapterCreators())
    }()

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adapter.collectionView = self.collectionView
        self.collectionView.contentInset.bottom = self.defaultBottomInset
        self.adapter.dataSource = self

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(rotated),
			name: UIDevice.orientationDidChangeNotification,
			object: nil
		)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateRefreshControlRect()
    }

    // MARK: - Refresh

    public func addRefreshControl(color: UIColor = MainTheme.shared.black) {
        if self.refreshControl != nil {
            return
        }
        self.collectionView.alwaysBounceVertical = true
        self.refreshControl = RefreshIndicator(style: .prominent)
        self.refreshControl?.indicator.lineColor = color
        self.collectionView.addSubview(self.refreshControl!)
        self.refreshControl?.addTarget(self,
                                       action: #selector(self.refresh),
                                       for: .valueChanged)
    }

    public func removeRefreshControl() {
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }

    public func updateRefreshControlRect() {
        self.refreshControl?.center.x = self.collectionView.bounds.width / 2
    }

    public func isRefreshing() -> Bool {
        return self.refreshControl?.isRefreshing ?? false
    }

    @objc
    public func refresh() {
        // override me
    }

	@objc
	private func rotated() {
		self.reload()
	}

    // MARK: - Methods

    public func adapterCreators() -> [AdapterCreator] {
        fatalError("Override me")
    }

    public func update(animated: Bool = true,
                       completion: ListUpdaterCompletion? = nil) {
        self.adapter.performUpdates(animated: animated, completion: completion)
    }

    public func reload(completion: ListUpdaterCompletion? = nil) {
        self.adapter.reloadData(completion: completion)
    }

    // MARK: - IGListAdapterDataSource

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.items
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return self.manager.adapter(from: object)
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension BaseCollectionViewController: RefreshBehavior {
    func showRefreshIndicator() -> ActivityDisposable? {
        if self.refreshActivity?.isDisposed == false {
            return self.refreshActivity
        }
        if self.isRefreshing() == false {
            self.refreshControl?.startRefreshing()
        }
        return self.createActivity()
    }

    private func createActivity() -> ActivityDisposable? {
        let activity = ActivityHolder { [weak self] in
            self?.refreshControl?.endRefreshing()
        }

        self.refreshActivity = activity
        return activity
    }
}

class InfinityCollectionViewController: BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewDelegate = self
    }

    public func loadMore() {
        // override me
    }
}

// MARK: - UIScrollViewDelegate

extension InfinityCollectionViewController: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if distance < 200 {
            self.loadMore()
        }
    }
}
