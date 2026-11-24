import UIKit

// MARK: - View Controller

final class FeedViewController: BaseCollectionViewController {
    var handler: FeedEventHandler!

    private lazy var searchButton = BarButton(image: .System.search,
                                              imageEdge: inset(0, 5, 0, 5)) { [weak self] in
        self?.handler.search()
    }

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: .System.refresh) { [weak self] in
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
        self.addRefreshControl(scrollView: collectionView)
        self.handler.didLoad()
        self.collectionView.contentInset.top = 10
        self.collectionView.contentInset.bottom = 16
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Feed.title
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.handler.refreshIfNeeded()
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    private func setupNavbar() {
        var items = [self.searchButton]
        #if targetEnvironment(macCatalyst)
        items.append(self.refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items, animated: false)
    }

    private func map(item: any Hashable) -> (any SectionAdapterProtocol)? {
        switch item {
        case let model as PromoViewModel:
            return SectionAdapter([PromoCellAdapter(viewModel: model)])
        case let model as SoonViewModel:
            return SoonSectionsAdapter(model)
        case let model as TitleItem:
            return SectionAdapter([TitleCellAdapter(viewModel: model)])
        case let items as [ActionItem]:
            return SectionAdapter(items.map(ActionCellAdapter.init))
        default:
            return nil
        }
    }
}

extension FeedViewController: FeedViewBehavior {
    func set(items: [any Hashable]) {
        set(sections: items.compactMap(map))
    }
}
