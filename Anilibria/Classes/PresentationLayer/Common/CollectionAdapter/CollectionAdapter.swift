//
//  CollectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

class CollectionViewAdapter: NSObject {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, AnyCellAdapter>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, AnyCellAdapter>

    private let collectionView: UICollectionView
    private var dataSource: DataSource!
    private let context: CollectionContext
    private var sectionsHolder: Any?
    private var adapterContext: AdapterContext!

    weak var scrollViewDelegate: UIScrollViewDelegate?
    private(set) weak var layout: UICollectionViewCompositionalLayout?

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.context = CollectionContext(collectionView)
        super.init()
        self.dataSource = makeDataSource()
        self.adapterContext = AdapterContext(dataSource: dataSource)
        self.collectionView.delegate = self
        self.setLayout()
    }

    func setLayout<Layout: UICollectionViewCompositionalLayout>(
        type: Layout.Type = UICollectionViewCompositionalLayout.self,
        populator: ((Layout) -> Void)? = nil
    ) {
        let layout = Layout(
            sectionProvider: { [weak self] sectionIndex, environment in
                guard
                    let self,
                    let section = dataSource.itemIdentifier(for: IndexPath(item: 0, section: sectionIndex))?.section
                else {
                    return nil
                }
                return section.getSectionLayout(environment: environment)
            }
        )
        populator?(layout)

        collectionView.collectionViewLayout = layout
        self.layout = layout
    }

    func set(sections: [any SectionAdapterProtocol], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.sectionsHolder = sections
        var snapshot = Snapshot()

        for section in sections {
            section.set(context: adapterContext)
            section.getIdentifiers().forEach { id in
                let sectionId = id.hashValue
                snapshot.appendSections([sectionId])
                snapshot.appendItems(section.getItems(for: id), toSection: sectionId)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
        if snapshot.itemIdentifiers.isEmpty {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] _, indexPath, item in
            guard let self = self else { return nil }
            return item.cellForItem(at: indexPath, context: self.context)
        }

        dataSource.supplementaryViewProvider = { [weak self] _, kind, indexPath in
            guard let self, let section = dataSource.itemIdentifier(for: indexPath)?.section else { return nil }
            return section.supplementaryFor(elementKind: kind, index: indexPath, context: context)
        }

        return dataSource
    }

    private func item(for index: IndexPath) -> AnyCellAdapter? {
        dataSource.itemIdentifier(for: index)
    }

    private func item(for section: Int) -> AnyCellAdapter? {
        dataSource.itemIdentifier(for: IndexPath(item: 0, section: section))
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

final class AdapterContext {
    private weak var dataSource: UICollectionViewDiffableDataSource<Int, AnyCellAdapter>?

    init(
        dataSource: UICollectionViewDiffableDataSource<Int, AnyCellAdapter>?
    ) {
        self.dataSource = dataSource
    }

    func reload(section: (any SectionAdapterProtocol)?, animated: Bool = true) {
        guard let section, let dataSource else { return }
        var snapshot = dataSource.snapshot()

        section.getIdentifiers().forEach { id in
            let current = snapshot.itemIdentifiers(inSection: id.hashValue)
            snapshot.deleteItems(current)
            snapshot.appendItems(section.getItems(for: id), toSection: id.hashValue)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
