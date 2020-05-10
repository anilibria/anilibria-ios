import IGListKit
import UIKit

// MARK: - View Controller

final class FeedViewController: InfinityCollectionViewController {
    var handler: FeedEventHandler!

    private lazy var searchButton = BarButton(image:#imageLiteral(resourceName: "menu_item_search.pdf"),
                                              imageEdge: inset(12, 5, 12, 5)) { [weak self] in
        self?.handler.search()
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image:#imageLiteral(resourceName: "icon_refresh")) { [weak self] in
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

    // MARK: - Adapter creators

    override func adapterCreators() -> [AdapterCreator] {
        return [
            SeriesCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(series: item)
            })),
            NewsCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(news: item)
            })),
            SoonCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(series: item)
            })),
            TitleCellAdapterCreator(),
            ActionCellAdapterCreator()
        ]
    }
}

extension FeedViewController: FeedViewBehavior {
    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }

    func loadPageProgress() -> ActivityDisposable? {
        return nil
    }
}
