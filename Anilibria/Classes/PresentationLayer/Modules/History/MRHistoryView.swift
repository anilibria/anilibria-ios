import IGListKit
import UIKit

// MARK: - View Controller

final class HistoryViewController: BaseCollectionViewController {
    var handler: HistoryEventHandler!

    private let searchView: SearchView? = SearchView.fromNib()
    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: #imageLiteral(resourceName: "icon_history"), color: .darkGray)
        $0.title = L10n.Stub.title
    }

    private var currentQuery: String = ""

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
                .subscribe(onNext: { [weak self] text in
                    self?.currentQuery = text
                    self?.handler.search(query: text)
                })
                .disposed(by: self.disposeBag)
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

    // MARK: - Adapter creators

    override func adapterCreators() -> [AdapterCreator] {
        return [
            RemovableSeriesCellAdapterCreator(.init(select: { [weak self] item in
                self?.searchView?.resignFirstResponder()
                self?.handler.select(series: item)
                }, delete: { [weak self] item in
                    self?.handler.delete(series: item)
            }))
        ]
    }

    override func emptyView(for listAdapter: ListAdapter) -> UIView? {
        var text = L10n.Stub.History.message
        if self.searchView?.isSearching == true {
            text = L10n.Stub.messageNotFound(self.currentQuery)
        }
        self.stubView?.message = text

        return self.stubView
    }
}

extension HistoryViewController: HistoryViewBehavior {
    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }
}
