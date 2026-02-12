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

    private var activity: ActivityDisposable?

    private lazy var reverseButton = BarButton(
        image: .System.upDownArrows,
        imageEdge: inset(5, 5, 5, 5)
    ) { [weak self] in
        self?.viewModel?.toggleDirection()
    }

    private lazy var optionsButton = BarButton(
        image: .System.pencil,
        imageEdge: inset(5, 5, 5, 5)
    ) { [weak self] in
        self?.viewModel?.showOptions()
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
        self.sectionAdapter.estimatedHeight = 182
        self.collectionView.contentInset.top = 10

        viewModel?.items.removeDuplicates().sink { [weak self] items in
            self?.set(items: items)
        }.store(in: &subscribers)

        viewModel?.didLoad()
    }

    private func setupNavbar() {
        if let value = self.searchView {
            self.navigationItem.titleView = value
            value.querySequence()
                .sink(onNext: { [weak self] text in
                    self?.viewModel?.search(query: text)
                    self?.stubView?.message = L10n.Stub.messageNotFound(text)
                })
                .store(in: &subscribers)
        }

        navigationItem.setRightBarButtonItems([optionsButton, reverseButton], animated: false)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.collectionView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.collectionView.contentInset.bottom = self.defaultBottomInset
    }
}

extension EpisodesViewController {
    func set(items: [EpisodeViewModel]?) {
        guard let items else {
            activity = showLoading(fullscreen: false)
            return
        }
        activity = nil
        if items.isEmpty {
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
