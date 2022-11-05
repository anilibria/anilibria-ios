import IGListKit
import UIKit

// MARK: - View Controller

final class FavoriteViewController: BaseCollectionViewController {
    var handler: FavoriteEventHandler!

    private let searchView: SearchView? = SearchView.fromNib()
    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: #imageLiteral(resourceName: "star-outline"), color: .darkGray)
        $0.title = L10n.Stub.title
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image:#imageLiteral(resourceName: "icon_refresh")) { [weak self] in
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

    override func adapterCreators() -> [AdapterCreator] {
        return [
            RemovableSeriesCellAdapterCreator(.init(select: { [weak self] item in
                self?.searchView?.resignFirstResponder()
                self?.handler.select(series: item)
                }, delete: { [weak self] item in
                    self?.handler.unfavorite(series: item)
            }))
        ]
    }

    override func emptyView(for listAdapter: ListAdapter) -> UIView? {
        var text = L10n.Stub.Favorite.message
        if self.searchView?.isSearching == true {
            text = L10n.Stub.messageNotFound(self.currentQuery)
        }
        self.stubView?.message = text

        return self.stubView
    }
}

extension FavoriteViewController: FavoriteViewBehavior {
    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }
}
