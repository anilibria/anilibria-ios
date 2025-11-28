//
//  EpisodesViewController.swift
//  AniLiberty
//
//  Created by Ivan Morozov on 28.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class EpisodesViewController: BaseCollectionViewController {
    private let searchView: SearchView? = SearchView(
        frame: CGRect(origin: .zero, size: .init(width: 320, height: 40))
    )

    private lazy var reverseButton = BarButton(
        image: .System.upDownArrows,
        imageEdge: inset(5, 5, 5, 5)
    ) { [weak self] in
        self?.viewModel?.toggleDirection()
    }

    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: .System.play, color: .Text.secondary)
        $0.title = L10n.Stub.title
    }

    private let sectionAdapter = SectionAdapter([])

    var viewModel: EpisodesViewModel?

    private lazy var episodesHandler = EpisodeCellAdapterHandler(
        select: { [weak self] item in
            self?.searchView?.resignFirstResponder()
            self?.viewModel?.play(item: item)
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavbar()
        self.addKeyboardObservers()
        self.sectionAdapter.estimatedHeight = 80
        self.collectionView.contentInset.top = 10

        viewModel?.items.removeDuplicates().sink { [weak self] items in
            self?.set(items: items)
        }.store(in: &subscribers)
    }

    private func setupNavbar() {
        if let value = self.searchView {
            self.navigationItem.titleView = value
            value.querySequence()
                .sink(onNext: { [weak self] text in
                    self?.viewModel?.search(query: text)
                })
                .store(in: &subscribers)
        }

        navigationItem.setRightBarButtonItems([reverseButton], animated: false)
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
        guard let searchView else { return }
        stubView?.message = if searchView.isSearching {
            L10n.Stub.messageNotFound(searchView.text)
        } else {
            ""
        }
    }
}

extension EpisodesViewController {
    func set(items: [PlaylistItem]) {
        if items.isEmpty {
            self.updateEmptyView()
            self.collectionView.backgroundView = self.stubView
        } else {
            self.collectionView.backgroundView = nil
        }

        sectionAdapter.set(items.map {
            EpisodeCellAdapter(viewModel: $0, handler: episodesHandler)
        })
        self.set(sections: [sectionAdapter])
    }
}
