import IGListKit
import RxCocoa
import RxSwift
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
        self.collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.bag = self.collectionView.observe(\UICollectionView.contentSize) { [weak self] _, _ in
            if let height = self?.collectionView.contentSize.height {
                self?.collectionHeightConstraint.constant = height
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
        self.searchField.rx.controlEvent(.editingChanged)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if let text = self?.searchField.text {
                    self?.handler.search(query: text)
                }
            })
            .disposed(by: self.disposeBag)
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

    // MARK: - Adapter creators

    override func adapterCreators() -> [AdapterCreator] {
        return [
            SearchResultAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(item: item)
            }))
        ]
    }

    @IBAction func backAction(_ sender: Any) {
        self.searchField.resignFirstResponder()
        self.searchField.isUserInteractionEnabled = false
        self.items = []
        self.update { [weak self] _ in
            self?.searchContainerConstraint.constant = 35
            UIView.animate(withDuration: 0.3,
                           animations: { self?.view.layoutIfNeeded() },
                           completion: { _ in self?.handler.back() })
        }
    }
}

extension SearchViewController: SearchViewBehavior {
    func set(items: [ListDiffable]) {
        self.scrollView.isScrollEnabled = !items.isEmpty
        self.items = items
        self.update()
    }
}
