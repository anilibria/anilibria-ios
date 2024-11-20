import UIKit

// MARK: - View Controller

final class FeedViewController: BaseCollectionViewController {
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

    private func setupNavbar() {
        var items = [self.searchButton]
        #if targetEnvironment(macCatalyst)
        items.append(self.refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items, animated: false)
    }

    private func map(item: any Hashable) -> (any SectionAdapterProtocol)? {
        switch item {
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
