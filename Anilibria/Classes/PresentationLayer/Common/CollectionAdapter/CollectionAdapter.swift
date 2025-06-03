//
//  CollectionAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

class CollectionViewAdapter: NSObject {

    typealias DataSource = UICollectionViewDiffableDataSource<SectionData, AnyCellAdapter>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionData, AnyCellAdapter>

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
        configuration: UICollectionViewCompositionalLayoutConfiguration? = nil,
        populator: ((Layout) -> Void)? = nil
    ) {
        let layout: Layout
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in
            guard
                let section = self?.dataSource.getSection(for: sectionIndex)
            else {
                return nil
            }
            return section.getSectionLayout(environment: environment)
        }

        if let configuration {
            layout = Layout(
                sectionProvider: provider,
                configuration: configuration
            )
        } else {
            layout = Layout(
                sectionProvider: provider
            )
        }
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
                let sectionId = SectionData(id: id, section: section)
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
            guard let self else { return nil }
            return item.cellForItem(at: indexPath, context: context)
        }

        dataSource.supplementaryViewProvider = { [weak self, weak dataSource] _, kind, indexPath in
            guard let self, let section = dataSource?.getSection(for: indexPath.section) else { return nil }
            return section.supplementaryFor(elementKind: kind, index: indexPath, context: context)
        }

        return dataSource
    }

    private func item(for index: IndexPath) -> AnyCellAdapter? {
        dataSource.itemIdentifier(for: index)
    }

    func item<T: AnyCellAdapter>(type: T.Type = T.self, for index: IndexPath) -> T? {
        dataSource.itemIdentifier(for: index) as? T
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
    private weak var dataSource: UICollectionViewDiffableDataSource<SectionData, AnyCellAdapter>?

    init(
        dataSource: UICollectionViewDiffableDataSource<SectionData, AnyCellAdapter>?
    ) {
        self.dataSource = dataSource
    }

    func reloadItems(in section: (any SectionAdapterProtocol)?, animated: Bool = true) {
        guard let section, let dataSource else { return }
        var snapshot = dataSource.snapshot()

        section.getIdentifiers().forEach { id in
            let sectionId = SectionData(id: id, section: section)
            let current = snapshot.itemIdentifiers(inSection: sectionId)
            snapshot.deleteItems(current)
            snapshot.appendItems(section.getItems(for: id), toSection: sectionId)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func reload(section: (any SectionAdapterProtocol)?, animated: Bool = true) {
        guard let section, let dataSource else { return }
        var snapshot = dataSource.snapshot()

        section.getIdentifiers().forEach { id in
            let sectionId = SectionData(id: id, section: section)
            if snapshot.sectionIdentifiers.contains(sectionId) {
                snapshot.deleteSections([sectionId])
            }
            snapshot.appendSections([sectionId])
            snapshot.appendItems(section.getItems(for: id), toSection: sectionId)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func removeSections(identifiers: Set<AnyHashable>, animated: Bool = true) {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()

        snapshot.deleteSections(identifiers.map { SectionData(id: $0, section: nil) })

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}


extension UICollectionViewDiffableDataSource {
    func getSection(for index: Int) -> SectionIdentifierType? {
        if #available(iOS 15.0, *) {
            self.sectionIdentifier(for: index)
        } else {
            self.snapshot().sectionIdentifiers[safe: index]
        }
    }
}
