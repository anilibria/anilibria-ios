//
//  LeftAlignedCollectionViewFlowLayout.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

open class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var insetCache: [Int: UIEdgeInsets] = [:]
    private var spacingCache: [Int: CGFloat] = [:]

    private var flowDelegate: UICollectionViewDelegateFlowLayout? {
        self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        insetCache = [:]
        spacingCache = [:]

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory != .cell { return }
            let section = layoutAttribute.indexPath.section
            let inset = insetForSection(at: section)
            let spacing = minimumInteritemSpacingForSection(at: section)

            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = inset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + spacing
            maxY = floor(max(layoutAttribute.frame.maxY , maxY))
        }

        return attributes
    }

    private func insetForSection(at section: Int) -> UIEdgeInsets {
        if let inset = insetCache[section] { return inset }

        guard let collectionView = self.collectionView else { return sectionInset }

        let result = flowDelegate?.collectionView?(
            collectionView,
            layout: self,
            insetForSectionAt: section
        ) ?? sectionInset

        insetCache[section] = result

        return result
    }

    private func minimumInteritemSpacingForSection(at section: Int) -> CGFloat {
        if let spacing = spacingCache[section] { return spacing }

        guard let collectionView = self.collectionView else { return minimumInteritemSpacing }

        let result = flowDelegate?.collectionView?(
            collectionView,
            layout: self,
            minimumInteritemSpacingForSectionAt: section
        ) ?? minimumInteritemSpacing

        spacingCache[section] = result

        return result
    }
}
