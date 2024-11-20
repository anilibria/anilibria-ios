import UIKit

// MARK: - View Controller

final class FavoriteViewController: BaseCollectionViewController {
    var handler: FavoriteEventHandler!

    private let searchView: SearchView? = SearchView.fromNib()
    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: UIImage(resource: .starOutline), color: UIColor(resource: .Text.secondary))
        $0.title = L10n.Stub.title
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: UIImage(resource: .iconRefresh)) { [weak self] in
        _ = self?.showRefreshIndicator()
        self?.collectionView.setContentOffset(.init(x: 0, y: -10), animated: false)
        self?.handler.refresh()
    }
    #endif

    private var currentQuery: String = ""
    private var sectionAdapter = SectionAdapter([])
    private lazy var seriesHandler = RemovableSeriesCellAdapterHandler(
        select: { [weak self] item in
            self?.searchView?.resignFirstResponder()
            self?.handler.select(series: item)
        },
        delete: { [weak self] item in
            self?.handler.unfavorite(series: item)
        }
    )

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
                .sink(onNext: { [weak self] text in
                    self?.currentQuery = text
                    self?.handler.search(query: text)
                })
                .store(in: &subscribers)
        }
        #if targetEnvironment(macCatalyst)
        self.navigationItem.setRightBarButtonItems([
            self.refreshButton
        ], animated: false)
        #endif
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
    func set(items: [Series]) {
        if items.isEmpty {
            self.updateEmptyView()
            self.collectionView.backgroundView = self.stubView
        } else {
            self.collectionView.backgroundView = nil
        }

        sectionAdapter.set(items.map {
            RemovableSeriesCellAdapter(viewModel: $0, handler: seriesHandler)
        })
        self.set(sections: [sectionAdapter])
    }
}
