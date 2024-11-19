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
    weak var layout: UICollectionViewCompositionalLayout?

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.context = CollectionContext(collectionView)
        super.init()
        self.dataSource = makeDataSource()
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, environment in
                guard
                    let self,
                    let data = self.content?.sections[safe: sectionIndex]
                else {
                    assertionFailure("layout is not found for section \(sectionIndex)")
                    return nil
                }
                return data.section.getSectionLayout(environment: environment)
            }
        )

        collectionView.collectionViewLayout = layout
        self.layout = layout
        self.collectionView.delegate = self
    }

    func reload(content: CollectionContent, animated: Bool = true, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()

        snapshot.appendSections(content.sections.compactMap { $0.sectionId })
        for section in content.sections {
            snapshot.appendItems(section.items, toSection: section.sectionId)
        }

        self.content = content
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
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
        self.content?.append(content)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] _, indexPath, wrapper in
            guard let self = self else { return nil }
            return wrapper.item.cellForItem(at: indexPath, context: self.context)
        }

        dataSource.supplementaryViewProvider = { [weak self] _, kind, indexPath in
            guard let self, let data = content?.sections[safe: indexPath.section] else { return nil }
            return data.section.supplementaryFor(elementKind: kind, index: indexPath, context: context)
        }

        return dataSource
    }

    private func item(for index: IndexPath) -> (any CellAdapterProtocol)? {
        dataSource.itemIdentifier(for: index)?.item
    }

    private func item(for section: Int) -> (any CellAdapterProtocol)? {
        dataSource.itemIdentifier(for: IndexPath(item: 0, section: section))?.item
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewAdapter: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        item(for: indexPath)?.didSelect(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        item(for: indexPath)?.willDisplay(at: indexPath)
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
