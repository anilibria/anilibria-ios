import UIKit

// MARK: - View Controller

final class HistoryViewController: BaseCollectionViewController {
    var handler: HistoryEventHandler!

    private let searchView: SearchView? = SearchView.fromNib()
    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: UIImage(resource: .iconHistory), color: UIColor(resource: .Text.secondary))
        $0.title = L10n.Stub.title
    }

    private var currentQuery: String = ""
    private var sectionAdapter = SectionAdapter([])
    private lazy var seriesHandler = RemovableSeriesCellAdapterHandler(
        select: { [weak self] item in
            self?.searchView?.resignFirstResponder()
            self?.handler.select(series: item)
        },
        delete: { [weak self] item in
            self?.handler.delete(series: item)
        }
    )

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavbar()
        self.addKeyboardObservers()
        self.handler.didLoad()
        self.collectionView.contentInset.top = 10
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
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.collectionView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.collectionView.contentInset.bottom = self.defaultBottomInset
    }

    func updateEmptyView() {
        var text = L10n.Stub.History.message
        if self.searchView?.isSearching == true {
            text = L10n.Stub.messageNotFound(self.currentQuery)
        }
        self.stubView?.message = text
    }
}

extension HistoryViewController: HistoryViewBehavior {
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
        self.reload(sections: [sectionAdapter])
    }
}
