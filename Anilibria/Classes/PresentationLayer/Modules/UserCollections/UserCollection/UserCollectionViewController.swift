//
//  UserCollectionViewController.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

// MARK: - View Controller

protocol UserCollectionViewModelProtocol: SeriesViewModelProtocol {
    var activityBehavior: (any ActivityBehavior)? { get set }
    var filterActive: AnyPublisher<Bool, Never> { get }
    func refresh()
    func search(query: String)
    func openFilter()
    func didLoad()
}

final class UserCollectionViewController: BaseCollectionViewController {
    @IBOutlet var searchView: SearchView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var refreshButton: UIButton!

    var viewModel: (any UserCollectionViewModelProtocol)!

    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: UIImage(systemName: "book"), color: UIColor(resource: .Text.secondary))
        $0.title = L10n.Stub.title
    }

    private var currentQuery: String = ""

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHeaderView()
        self.addRefreshControl(scrollView: collectionView)
        self.addKeyboardObservers()
        self.setup()
    }

    override func refresh() {
        super.refresh()
        viewModel.refresh()
    }

    private func setupHeaderView() {
        self.searchView.querySequence()
            .dropFirst()
            .map {
                let result = $0.trim()
                if result.count > 1 {
                    return result
                }
                return ""
            }
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink(onNext: { [weak self] text in
                self?.currentQuery = text
                self?.viewModel.search(query: text)
            })
            .store(in: &subscribers)

        filterButton.publisher(for: .touchUpInside).sink { [weak self] in
            self?.viewModel.openFilter()
        }.store(in: &subscribers)

        #if targetEnvironment(macCatalyst)
        refreshButton.publisher(for: .touchUpInside).sink { [weak self] in
            _ = self?.showRefreshIndicator()
            self?.collectionView.setContentOffset(.init(x: 0, y: -10), animated: false)
            self?.viewModel.refresh()
        }.store(in: &subscribers)
        #else
        refreshButton.isHidden = true
        #endif
    }

    private func setup() {
        viewModel.activityBehavior = self
        collectionView.contentInset.top = 10
        scrollToTop()

        viewModel.items.dropFirst().sink { [weak self] items in
            if items.isEmpty {
                self?.updateEmptyView()
                self?.collectionView.backgroundView = self?.stubView
            } else {
                self?.collectionView.backgroundView = nil
            }
        }.store(in: &subscribers)

        set(sections: [SeriesSectionsAdapter(viewModel)])

        viewModel.filterActive.sink { [weak self] active in
            guard let self else { return }
            scrollToTop()
            filterButton.tintColor = if active {
                UIColor(resource: .Tint.active)
            } else {
                UIColor(resource: .Tint.main)
            }
        }.store(in: &subscribers)

        viewModel.didLoad()
    }

    private func scrollToTop() {
        collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.collectionView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.collectionView.contentInset.bottom = self.defaultBottomInset
    }

    private func updateEmptyView() {
        var text = L10n.Stub.Collection.message
        if self.searchView?.isSearching == true {
            text = L10n.Stub.messageNotFound(self.currentQuery)
        }
        self.stubView?.message = text
    }
}
