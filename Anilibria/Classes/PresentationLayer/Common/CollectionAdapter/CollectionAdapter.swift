//
//  CollectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

class CollectionViewAdapter: NSObject {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, CellAdapterWrapper>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, CellAdapterWrapper>

    private let collectionView: UICollectionView
    private var dataSource: DataSource!
    private let context: CollectionContext
    private var content: CollectionContent?

    weak var scrollViewDelegate: UIScrollViewDelegate?

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.context = CollectionContext(collectionView)
        super.init()
        self.dataSource = makeDataSource()
        self.collectionView.delegate = self
    }

    func reload(content: CollectionContent, animated: Bool = true, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()

        snapshot.appendSections(content.sections.compactMap { $0.sectionId })
        for section in content.sections {
            snapshot.appendItems(section.items, toSection: section.sectionId)
        }

        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
        self.content = content
    }

    func append(content: CollectionContent, animated: Bool = true, completion: (() -> Void)? = nil) {
        var snapshot = dataSource.snapshot()

        snapshot.appendSections(content.sections.compactMap {
            if self.content?.contains($0) == true {
                return nil
            }
            return $0.sectionId
        })
        for section in content.sections {
            let currentItems = snapshot.itemIdentifiers
            let toDelete = section.items.filter { currentItems.contains($0) }
            if !toDelete.isEmpty {
                snapshot.deleteItems(toDelete)
            }
            
            snapshot.appendItems(section.items, toSection: section.sectionId)
        }

        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
        self.content?.append(content)
    }

    private func makeDataSource() -> DataSource {
        let source = DataSource(collectionView: collectionView) { [weak self] _, indexPath, wrapper in
            guard let self = self else { return nil }
            return wrapper.item.cellForItem(at: indexPath, context: self.context)
        }
        
        source.supplementaryViewProvider = { [weak self] (_, kind, indexPath) -> UICollectionReusableView? in
            return self?.supplementary(kind: kind, indexPath: indexPath)
        }
        return source
    }
    
    private func supplementary(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        item(for: indexPath)?.section?.supplementaryForItem(at: indexPath, kind: kind, context: context)
    }

    private func item(for index: IndexPath) -> (any CellAdapterProtocol)? {
        dataSource.itemIdentifier(for: index)?.item
    }

    private func item(for section: Int) -> (any CellAdapterProtocol)? {
        dataSource.itemIdentifier(for: IndexPath(item: 0, section: section))?.item
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        item(for: indexPath)?.didSelect(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        item(for: indexPath)?.willDisplay(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        item(for: indexPath)?.sizeForItem(at: indexPath,
                                          collectionView: collectionView,
                                          layout: collectionViewLayout) ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        item(for: section)?
            .section?
            .collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        item(for: section)?
            .section?
            .collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        item(for: section)?
            .section?
            .collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        item(for: section)?
            .section?
            .collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        item(for: section)?
            .section?
            .collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) ?? .zero
    }

}

// MARK: - UIScrollViewDelegate
extension CollectionViewAdapter {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
}
