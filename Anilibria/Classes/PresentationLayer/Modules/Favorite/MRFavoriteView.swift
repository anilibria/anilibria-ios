import UIKit

// MARK: - View Controller

final class FavoriteViewController: BaseCollectionViewController {
    var handler: FavoriteEventHandler!

    private let searchView: SearchView? = SearchView.fromNib()
    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: UIImage(resource: .starOutline), color: UIColor(resource: .Text.secondary))
        $0.title = L10n.Stub.title
    }

    private lazy var filterButton = BarButton(image: UIImage(resource: .iconFilter)) { [weak self] in
        self?.handler.openFilter()
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: UIImage(resource: .iconRefresh)) { [weak self] in
        _ = self?.showRefreshIndicator()
        self?.collectionView.setContentOffset(.init(x: 0, y: -10), animated: false)
        self?.handler.refresh()
    }
    #endif

    private var currentQuery: String = ""

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavbar()
        self.addRefreshControl()
        self.addKeyboardObservers()
        self.handler.didLoad()
        self.collectionView.contentInset.top = 10
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    private func setupNavbar() {
        if let value = self.searchView {
            self.navigationItem.titleView = value
            value.querySequence()
                .dropFirst()
                .map {
                    let result = $0.trim()
                    if result.count > 1 {
                        return result
                    }
                    return ""
                }
                .removeDuplicates()
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .sink(onNext: { [weak self] text in
                    self?.currentQuery = text
                    self?.handler.search(query: text)
                })
                .store(in: &subscribers)
        }
        var items = [self.filterButton]
        #if targetEnvironment(macCatalyst)
        items.append(self.refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items ,animated: false)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.collectionView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.collectionView.contentInset.bottom = self.defaultBottomInset
    }

    // MARK: - Adapter creators

    func updateEmptyView() {
        var text = L10n.Stub.Favorite.message
        if self.searchView?.isSearching == true {
            text = L10n.Stub.messageNotFound(self.currentQuery)
        }
        self.stubView?.message = text
    }
}

extension FavoriteViewController: FavoriteViewBehavior {
    func seriesSelected() {
        searchView?.resignFirstResponder()
    }

    func scrollToTop() {
        self.collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
    }

    func set(model: FavoriteViewModel) {
        scrollToTop()
        model.items.dropFirst().sink { [weak self] items in
            if items.isEmpty {
                self?.updateEmptyView()
                self?.collectionView.backgroundView = self?.stubView
            } else {
                self?.collectionView.backgroundView = nil
            }
        }.store(in: &subscribers)

        self.set(sections: [SeriesSectionsAdapter(model)])
    }

    func setFilter(active: Bool) {
        self.filterButton.tintColor = if active {
            UIColor(resource: .Tint.active)
        } else {
            UIColor(resource: .Tint.main)
        }
    }
}
