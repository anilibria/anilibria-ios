import UIKit

final class SearchViewController: BaseCollectionViewController {
    var handler: SearchEventHandler!

    private lazy var search = UISearchController(searchResultsController: nil)
    private var didActivateSearch = false

    override func loadView() {
        view = UIView()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    override func viewDidLoad() {
        defaultBottomInset = 12
        super.viewDidLoad()
        definesPresentationContext = true
        search.obscuresBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = false
        search.automaticallyShowsCancelButton = false
        search.delegate = self
        search.searchResultsUpdater = self
        search.searchBar.searchTextField.accessibilityIdentifier = "search.query"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
            self?.handler.back()
        })
        handler.didLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didActivateSearch else { return }
        didActivateSearch = true
        search.isActive = true
    }

    override func setupStrings() {
        navigationItem.title = L10n.Screen.Catalog.title
        search.searchBar.placeholder = L10n.Common.Search.byName
    }
}

extension SearchViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }

    func updateSearchResults(for searchController: UISearchController) {
        handler.search(query: searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: SearchViewBehavior {
    func set(items: [SearchValue]) {
        if #available(iOS 17.0, *) {
            contentUnavailableConfiguration = nil
        }
        let section = SectionAdapter(items.map {
            SearchResultAdapter(viewModel: $0, seclect: { [weak self] item in
                self?.handler.select(item: item)
            })
        })
        section.minimumColumnWidth = 285
        set(sections: [section], animated: false)
    }

    func showSearchFailure() {
        if #available(iOS 17.0, *) {
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.text = L10n.Common.Search.unavailable
            configuration.button = .tinted()
            configuration.button.title = L10n.Buttons.retry
            configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
                self?.handler.retry()
            }
            contentUnavailableConfiguration = configuration
        }
    }
}
