//
//  EpisodesView.swift
//  AniLiberty
//
//  Created by Ivan Morozov on 30.04.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class EpisodesView: UIView {
    private static let actionsViewHeight: CGFloat = 44

    private var actionTopConstraint: NSLayoutConstraint?
    private var actionBottomConstraint: NSLayoutConstraint?

    private let actionsContainer: UIVisualEffectView = {
        if #available(iOS 26.0, *) {
            let view = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
            view.cornerConfiguration = .capsule()
            return view
        }
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.layer.cornerRadius = EpisodesView.actionsViewHeight / 2
        view.clipsToBounds = true
        return view
    }()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    public lazy var adapter = CollectionViewAdapter(collectionView: collectionView)

    private let searchField = UISearchTextField()
    private let reverseButton = UIButton(type: .system)
    private let optionsButton = UIButton(type: .system)

    private let stubView: StubView? = StubView.fromNib()?.apply {
        $0.set(image: .System.play, color: .Text.secondary)
        $0.title = L10n.Stub.title
        $0.message = L10n.Stub.noEpisodes
    }

    private let sectionAdapter = EpisodesSectionAdapter([])

    private var subscribers = Set<AnyCancellable>()
    private var itemsSubscribers = Set<AnyCancellable>()
    private var viewModel: EpisodesViewModel?

    private lazy var episodesHandler = EpisodeCellAdapterHandler(
        select: { [weak self] item in
            self?.searchField.resignFirstResponder()
            self?.viewModel?.play(item: item)
        }
    )

    var isCompact: Bool = true {
        didSet {
            actionTopConstraint?.isActive = !isCompact
            actionBottomConstraint?.isActive = isCompact
            sectionAdapter.isCompact = isCompact
            stubView?.isHorizontal = isCompact

            if isCompact {
                collectionView.contentInset.top = 0
                let conf = UICollectionViewCompositionalLayoutConfiguration()
                conf.scrollDirection = .horizontal
                self.adapter.setLayout(
                    type: UICollectionViewCompositionalLayout.self,
                    configuration: conf
                )
                stubView?.messageLinesLimit = 3
            } else {
                collectionView.contentInset.top = 16 + Self.actionsViewHeight
                self.adapter.setLayout(
                    type: UICollectionViewCompositionalLayout.self
                )
                stubView?.messageLinesLimit = 0
            }
            invalidateLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(collectionView)
        collectionView.constraintEdgesToSuperview()
        addSubview(actionsContainer)
        actionsContainer.translatesAutoresizingMaskIntoConstraints = false
        actionBottomConstraint = actionsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        actionTopConstraint = actionsContainer.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        NSLayoutConstraint.activate([
            actionsContainer.heightAnchor.constraint(equalToConstant: Self.actionsViewHeight),
            actionsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            actionsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
        ])
        isCompact = true

        self.setupSearchView()
        self.addKeyboardObservers()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }

    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func configure(viewModel: EpisodesViewModel) {
        self.viewModel = viewModel
        itemsSubscribers.removeAll()
        viewModel.items.removeDuplicates().sink { [weak self] items in
            self?.set(items: items)
        }.store(in: &itemsSubscribers)

        viewModel.$isEmpty.removeDuplicates().sink { [weak self] empty in
            guard let self else { return }
            reverseButton.isHidden = empty
            optionsButton.isHidden = empty
        }.store(in: &itemsSubscribers)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                self?.updateKeyboard(notification)
            }
            .store(in: &subscribers)
    }

    private func updateKeyboard(_ note: Notification) {
        guard
            !isCompact,
            let info = note.userInfo,
            let endFrameScreen = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let endFrameInView = convert(endFrameScreen, from: nil)
        let overlap = bounds.intersection(endFrameInView).height

        collectionView.contentInset.bottom = max(0, overlap - safeAreaInsets.bottom)
    }

    private func setupSearchView() {
        searchField.placeholder = L10n.Common.Search.byName
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.accessibilityIdentifier = "episodes.query"
        reverseButton.setImage(.System.upDownArrows, for: .normal)
        reverseButton.accessibilityLabel = L10n.Screen.Filter.sotring
        optionsButton.setImage(.System.pencil, for: .normal)
        optionsButton.accessibilityLabel = L10n.Buttons.settings

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        actionsContainer.contentView.addSubview(stackView)
        stackView.constraintEdgesToSuperview(.init(left: 6, right: 6))
        stackView.addArrangedSubview(searchField)
        stackView.addArrangedSubview(reverseButton)
        stackView.addArrangedSubview(optionsButton)
        let optionsWidth = optionsButton.widthAnchor.constraint(equalToConstant: 44)
        let reverseWidth = reverseButton.widthAnchor.constraint(equalToConstant: 44)
        optionsWidth.priority = .defaultHigh
        reverseWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([optionsWidth, reverseWidth])

        searchField.textPublisher
            .map { $0 ?? "" }
            .removeDuplicates()
            .sink(onNext: { [weak self] text in
                self?.viewModel?.search(query: text)
                if text.isEmpty {
                    self?.stubView?.message = L10n.Stub.noEpisodes
                } else {
                    self?.stubView?.message = L10n.Stub.messageNotFound(text)
                }
            })
            .store(in: &subscribers)
        searchField.publisher(for: .primaryActionTriggered).sink { [weak self] in
            self?.searchField.resignFirstResponder()
        }
        .store(in: &subscribers)

        optionsButton.publisher(for: .touchUpInside).sink { [weak self] in
            self?.viewModel?.showOptions()
        }
        .store(in: &subscribers)

        reverseButton.publisher(for: .touchUpInside).sink { [weak self] in
            self?.viewModel?.toggleDirection()
        }
        .store(in: &subscribers)
    }
}

extension EpisodesView {
    func set(items: [EpisodeViewModel]?) {
        guard let items else {
            return
        }
        if items.isEmpty {
            self.collectionView.backgroundView = self.stubView
        } else {
            self.collectionView.backgroundView = nil
        }

        sectionAdapter.set(items.map {
            EpisodeCellAdapter(viewModel: $0, handler: episodesHandler)
        })
        adapter.set(sections: [sectionAdapter])
    }
}
