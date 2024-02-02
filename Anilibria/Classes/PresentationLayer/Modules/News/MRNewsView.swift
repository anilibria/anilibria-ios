import UIKit

// MARK: - View Controller

final class NewsViewController: BaseCollectionViewController {
    var handler: NewsEventHandler!

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: UIImage(resource: .iconRefresh)) { [weak self] in
        _ = self?.showRefreshIndicator()
        self?.collectionView.setContentOffset(.init(x: 0, y: -10), animated: false)
        self?.handler.refresh()
    }
    #endif

    private let sectionAdapter = SectionAdapter([])

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
        self.navigationItem.title = L10n.Screen.News.title
    }

    private func setupNavbar() {
        #if targetEnvironment(macCatalyst)
        self.navigationItem.setRightBarButtonItems([
            self.refreshButton
        ], animated: false)
        #endif
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    // MARK: - Adapter creators

    private func createAdapter(for model: NSObject) -> (any CellAdapterProtocol)? {
        switch model {
        case let item as News:
            return NewsCellAdapter(viewModel: item, seclect: { [weak self] item in
                self?.handler.select(news: item)
            })
        case let item as PaginationViewModel:
            return PaginationAdapter(viewModel: item)
        default:
            return nil
        }
        
    }
}

extension NewsViewController: NewsViewBehavior {
    func loadPageProgress() -> ActivityDisposable? {
        return nil
    }

    func set(items: [NSObject]) {
        sectionAdapter.set(items.compactMap(createAdapter))
        reload(sections: [sectionAdapter])
    }

    func append(items: [NSObject]) {
        sectionAdapter.set(items.compactMap(createAdapter))
        append(sections: [sectionAdapter])
    }
}
