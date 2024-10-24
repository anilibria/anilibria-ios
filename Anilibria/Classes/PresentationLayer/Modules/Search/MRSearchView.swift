import Combine
import UIKit

// MARK: - View Controller

final class SearchViewController: BaseCollectionViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var searchContainerConstraint: NSLayoutConstraint!
    @IBOutlet var searchField: UITextField!

    var handler: SearchEventHandler!

    private var bag: Any?

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.defaultBottomInset = 0
        super.viewDidLoad()
        self.addKeyboardObservers()
        self.handler.didLoad()

        self.scrollView.isScrollEnabled = false
        self.collectionView.layer.cornerRadius = 5
        self.collectionHeightConstraint.constant = 1
        self.collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.bag = self.collectionView.observe(\UICollectionView.contentSize) { [weak self] _, _ in
            if let height = self?.collectionView.contentSize.height {
                self?.collectionHeightConstraint.constant = max(height, 1)
                UIView.animate(withDuration: 0.2) {
                    self?.view.layoutIfNeeded()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showSearchView()
        }
    }

    private func setupSearchField() {
        self.searchField.placeholder = L10n.Common.Search.byName
        self.searchField.publisher(for: .editingChanged)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink(onNext: { [weak self] in
                if let text = self?.searchField.text {
                    self?.handler.search(query: text)
                }
            })
            .store(in: &subscribers)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        self.scrollView.contentInset.bottom = keyboardHeight + 20
    }

    override func keyBoardWillHide() {
        self.scrollView.contentInset.bottom = 20
    }

    private func showSearchView() {
        let width = UIApplication.getWindow()?.frame.width ?? 0
        self.searchContainerConstraint.constant = width - 32
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.searchField.becomeFirstResponder()
        self.setupSearchField()
    }

    @IBAction func backAction(_ sender: Any) {
        self.searchField.resignFirstResponder()
        self.searchField.isUserInteractionEnabled = false
        self.reload(sections: []) { [weak self] in
            self?.searchContainerConstraint.constant = 35
            UIView.animate(withDuration: 0.3,
                           animations: { self?.view.layoutIfNeeded() },
                           completion: { _ in self?.handler.back() })
        }
    }
}

extension SearchViewController: SearchViewBehavior {
    func set(items: [SearchValue]) {
        self.scrollView.isScrollEnabled = !items.isEmpty
        self.reload(sections:[
            SectionAdapter(
                items.map {
                    SearchResultAdapter(viewModel: $0) { [weak self] item in
                        self?.handler.select(item: item)
                    }
                }
            )
        ])
    }
}
