import UIKit

// MARK: - View Controller

final class CatalogViewController: BaseCollectionViewController {
    var handler: CatalogEventHandler!

    private lazy var searchButton = BarButton(image: .System.search,
                                              imageEdge: inset(0, 5, 0, 5)) { [weak self] in
        self?.handler.search()
    }

    private lazy var filterButton = BarButton(image: .iconFilter) { [weak self] in
        self?.handler.openFilter()
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: .System.refresh) { [weak self] in
        _ = self?.showRefreshIndicator()
        self?.scrollToTop()
        self?.handler.refresh()
    }
    #endif

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavbar()
        self.addRefreshControl(scrollView: collectionView)
        self.handler.didLoad()
        self.collectionView.contentInset.top = 10
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Catalog.title
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    private func setupNavbar() {
        var items = [self.searchButton, self.filterButton]
        #if targetEnvironment(macCatalyst)
        items.append(self.refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items ,animated: false)
    }
}

extension CatalogViewController: CatalogViewBehavior {
    func scrollToTop() {
        self.collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
    }

    func set(model: CatalogViewModel) {
        scrollToTop()
        self.set(sections: [SeriesSectionsAdapter(model)])
    }

    func setFilter(active: Bool) {
        self.filterButton.tintColor = if active {
            .Tint.active
        } else {
            .Tint.main
        }
    }
}
