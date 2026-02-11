//
//  UserCollectionsViewController.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class UserCollectionsViewController: BaseCollectionViewController {
    @IBOutlet var collectionHeight: NSLayoutConstraint!
    @IBOutlet var pagerView: PagerView!

    override var isNavigationBarVisible: Bool { false }

    var viewModel: UserCollectionsViewModel!
    var pages: Dictionary<UserCollectionKey, UIViewController> = [:]
    private var keysSection: UserCollectionKeySectionAdapter?

    // MARK: - Life cycle

    override func viewDidLoad() {
        defaultBottomInset = 0
        super.viewDidLoad()
        view.backgroundColor = .Surfaces.background
        setupPager()
    }

    func setupPager() {
        self.pagerView.delegate = self
        self.pagerView.isScrollEnabled = false
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.dragInteractionEnabled = true
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.layoutMargins = .zero
        if UIDevice.current.userInterfaceIdiom != .pad {
            let conf = UICollectionViewCompositionalLayoutConfiguration()
            conf.scrollDirection = .horizontal
            self.adapter.setLayout(configuration: conf)
        }

        let section = UserCollectionKeySectionAdapter(
            keys: viewModel.collections
        )

        section.didSelect = { [weak self] key in
            guard let self else { return }
            if let index = viewModel.collections.firstIndex(of: key) {
                pagerView.scrollTo(index: index, animated: false)
            }
        }
        set(sections: [section])
        keysSection = section

        collectionView.publisher(for: \.contentSize).sink { [weak self] size in
            self?.collectionHeight.constant = size.height
        }.store(in: &subscribers)

        self.pagerView.scrollTo(index: 0, animated: false)
    }
}

extension UserCollectionsViewController: PagerViewDelegate {
    func numberOfPages(for pagerView: PagerView) -> Int {
        viewModel.collections.count
    }

    func pagerView(_ pagerView: PagerView, pageFor index: Int) -> UIViewController? {
        guard let key = viewModel.collections[safe: index] else {
            return nil
        }
        return pages[key]
    }
}

extension UserCollectionsViewController: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: any UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        if let key: UserCollectionKey = viewModel.collections[safe: indexPath.item] {
            let dragItem = UIDragItem(itemProvider: .init())
            dragItem.localObject = key
            return [dragItem]
        }
        return []
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dragSessionIsRestrictedToDraggingApplication session: any UIDragSession
    ) -> Bool {
        return true
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dragPreviewParametersForItemAt indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        makePreview(collectionView, indexPath: indexPath)
    }

    private func makePreview(
        _ collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        let bounds = cell.contentView.bounds
        let params = UIDragPreviewParameters()
        params.visiblePath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
        params.backgroundColor = .clear
        return params
    }
}

extension UserCollectionsViewController: UICollectionViewDropDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        canHandle session: any UIDropSession
    ) -> Bool {
        session.items.first?.localObject is UserCollectionKey
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dropPreviewParametersForItemAt indexPath: IndexPath
    ) -> UIDragPreviewParameters? {
        makePreview(collectionView, indexPath: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: any UICollectionViewDropCoordinator
    ) {
        guard
            let destinationIndex = coordinator.destinationIndexPath,
            let item = coordinator.items.first,
            let sourceIndex = item.sourceIndexPath,
            sourceIndex != destinationIndex
        else {
            return
        }
        if sourceIndex.item != destinationIndex.item {
            var items = viewModel.collections
            let key = items.remove(at: sourceIndex.item)
            items.insert(key, at: destinationIndex.item)
            viewModel.collections = items

            if let keysSection {
                keysSection.update(keys: viewModel.collections)
                set(sections: [keysSection])
            }
        }
        coordinator.drop(item.dragItem, toItemAt: destinationIndex)
    }
}
