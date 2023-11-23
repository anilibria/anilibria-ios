import UIKit

// MARK: - View Controller

final class FeedViewController: InfinityCollectionViewController {
    var handler: FeedEventHandler!

    private lazy var searchButton = BarButton(image: UIImage(resource: .menuItemSearch),
                                              imageEdge: inset(12, 5, 12, 5)) { [weak self] in
        self?.handler.search()
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: UIImage(resource: .iconRefresh)) { [weak self] in
        _ = self?.showRefreshIndicator()
        self?.collectionView.setContentOffset(.init(x: 0, y: -10), animated: false)
        self?.handler.refresh()
    }
    #endif

    var bag: Any?

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
        self.navigationItem.title = L10n.Screen.Feed.title
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    override func loadMore() {
        super.loadMore()
        self.handler.loadMore()
    }

    private func setupNavbar() {
        var items = [self.searchButton]
        #if targetEnvironment(macCatalyst)
        items.append(self.refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items, animated: false)
    }

    private func map(item: NSObject) -> (any CellAdapterProtocol)? {
        switch item {
        case let model as Series:
            return SeriesCellAdapter(viewModel: model) { [weak self] item in
                self?.handler.select(series: item)
            }
        case let model as News:
            return NewsCellAdapter(viewModel: model) { [weak self] item in
                self?.handler.select(news: item)
            }
        case let model as Schedule:
            return SoonCellAdapter(viewModel: model) { [weak self] item in
                self?.handler.select(series: item)
            }
        case let model as TitleItem:
            return TitleCellAdapter(viewModel: model)
        case let model as ActionItem:
            return ActionCellAdapter(viewModel: model)
        default:
            return nil
        }
    }
}

extension FeedViewController: FeedViewBehavior {
    func set(items: [NSObject]) {
        reload(sections: [SectionAdapter(items.compactMap(self.map(item:)))])
    }

    func append(items: [NSObject]) {
        append(sections: [SectionAdapter(items.compactMap(self.map(item:)))])
    }

    func loadPageProgress() -> ActivityDisposable? {
        return nil
    }
}
