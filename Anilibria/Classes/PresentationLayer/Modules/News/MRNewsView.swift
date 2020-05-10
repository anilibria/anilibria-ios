import IGListKit
import UIKit

// MARK: - View Controller

final class NewsViewController: InfinityCollectionViewController {
    var handler: NewsEventHandler!

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image:#imageLiteral(resourceName: "icon_refresh")) { [weak self] in
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

    override func loadMore() {
        super.loadMore()
        self.handler.loadMore()
    }

    // MARK: - Adapter creators

    override func adapterCreators() -> [AdapterCreator] {
        return [
            NewsCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(news: item)
            }))
        ]
    }
}

extension NewsViewController: NewsViewBehavior {
    func loadPageProgress() -> ActivityDisposable? {
        return nil
    }

    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }
}
