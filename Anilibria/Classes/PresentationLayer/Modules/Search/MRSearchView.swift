import Combine
import UIKit

// MARK: - View Controller

final class SearchViewController: BaseCollectionViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var searchContainerConstraint: NSLayoutConstraint!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var backview: UIView!

    var handler: SearchEventHandler!

    private var bag: Any?
    private var items: [SearchValue] = []
    private var highlightedIndex: Int?

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.defaultBottomInset = 0
        super.viewDidLoad()
        collectionView.layoutMargins = .zero
        view.backgroundColor = .black.withAlphaComponent(0.5)
        addKeyboardObservers()
        handler.didLoad()

        scrollView.isScrollEnabled = false
        collectionHeightConstraint.constant = 1
        backview.layer.cornerRadius = 5
        backview.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.layer.cornerRadius = 5
        collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bag = collectionView.publisher(for: \.contentSize).removeDuplicates().sink { [weak self] _ in
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

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        let escape = UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(self.dismissSearchAction)
        )

        if #available(iOS 15.0, macCatalyst 15.0, *) {
            escape.wantsPriorityOverSystemBehavior = true
        }

        guard !items.isEmpty else { return [escape] }

        let up = UIKeyCommand(
            input: UIKeyCommand.inputUpArrow,
            modifierFlags: [],
            action: #selector(self.moveHighlightUp)
        )

        let down = UIKeyCommand(
            input: UIKeyCommand.inputDownArrow,
            modifierFlags: [],
            action: #selector(self.moveHighlightDown)
        )

        let select = UIKeyCommand(
            input: "\r",
            modifierFlags: [],
            action: #selector(self.selectHighlighted)
        )

        if #available(iOS 15.0, macCatalyst 15.0, *) {
            up.wantsPriorityOverSystemBehavior = true
            down.wantsPriorityOverSystemBehavior = true
        }

        return [escape, up, down, select]
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
        self.set(sections: []) { [weak self] in
            self?.searchContainerConstraint.constant = 35
            UIView.animate(withDuration: 0.3,
                           animations: { self?.view.layoutIfNeeded() },
                           completion: { _ in self?.handler.back() })
        }
    }

    @objc private func dismissSearchAction() {
        self.backAction(self)
    }

    // MARK: - Keyboard navigation

    @objc private func moveHighlightUp() {
        guard !items.isEmpty else { return }
        let newIndex: Int
        if let current = highlightedIndex {
            newIndex = max(current - 1, 0)
        } else {
            newIndex = items.count - 1
        }
        highlight(index: newIndex)
    }

    @objc private func moveHighlightDown() {
        guard !items.isEmpty else { return }
        let newIndex: Int
        if let current = highlightedIndex {
            newIndex = min(current + 1, items.count - 1)
        } else {
            newIndex = 0
        }
        highlight(index: newIndex)
    }

    @objc private func selectHighlighted() {
        guard let index = highlightedIndex, let item = items[safe: index] else { return }
        self.handler.select(item: item)
    }

    private func highlight(index: Int) {
        let previous = highlightedIndex
        highlightedIndex = index

        if let previous, let cell = collectionView.cellForItem(at: IndexPath(item: previous, section: 0)) {
            cell.isSelected = false
        }

        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.isSelected = true
        }
    }
}

extension SearchViewController: SearchViewBehavior {
    func set(items: [SearchValue]) {
        self.items = items
        self.highlightedIndex = nil
        self.scrollView.isScrollEnabled = !items.isEmpty
        self.set(sections:[
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
