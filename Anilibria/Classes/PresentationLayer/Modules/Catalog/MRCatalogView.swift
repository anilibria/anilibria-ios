import UIKit

// MARK: - View Controller

final class CatalogViewController: BaseCollectionViewController {
    var handler: CatalogEventHandler!

    private lazy var searchButton = BarButton(image: UIImage(resource: .menuItemSearch),
                                              imageEdge: inset(12, 5, 12, 5)) { [weak self] in
        self?.handler.search()
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

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavbar()
        self.addRefreshControl()
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

    private func createAdapter(for model: any Hashable) -> (any CellAdapterProtocol)? {
        switch model {
        case let item as Series:
            return SeriesCellAdapter(viewModel: item, seclect: { [weak self] item in
                self?.handler.select(series: item)
            })
        case let item as PaginationViewModel:
            return PaginationAdapter(viewModel: item)
        default:
            return nil
        }
    }
}

extension CatalogViewController: CatalogViewBehavior {
    func set(items: [any Hashable]) {
        self.collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
        self.reload(sections: [SectionAdapter(items.compactMap(createAdapter))])
    }

    func append(items: [any Hashable]) {
        append(sections: [SectionAdapter(items.compactMap(createAdapter))])
    }

    func setFilter(active: Bool) {
        self.filterButton.tintColor = if active {
            UIColor(resource: .Tint.active)
        } else {
            UIColor(resource: .Tint.main)
        }
    }

    func loadPageProgress() -> ActivityDisposable? {
        return nil
    }
}
