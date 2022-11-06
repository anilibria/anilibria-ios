//
//  CollectionContext.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

public class CollectionContext {
    private var registeredCells: Set<String> = []
    private var registeredSupplementaries: [String: Set<String>] = [:]
    private weak var collectioView: UICollectionView?

    init(_ collectionView: UICollectionView) {
        self.collectioView = collectionView
    }

    public func dequeueReusableCell<CellType: UICollectionViewCell>(
        type: CellType.Type,
        for indexPath: IndexPath
    ) -> CellType {
        let identifier = String(describing: type)
        if !registeredCells.contains(identifier) {
            self.collectioView?.register(CellType.self, forCellWithReuseIdentifier: identifier)
            self.registeredCells.insert(identifier)
        }

        guard let cell = self.collectioView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? CellType else {
            preconditionFailure("collectioView is nil or cell not registered")
        }

        return cell
    }

    public func dequeueReusableNibCell<CellType: UICollectionViewCell>(
        type: CellType.Type,
        for indexPath: IndexPath
    ) -> CellType {
        let nibName = String(describing: type)
        if !registeredCells.contains(nibName) {
            let nib = UINib(nibName: nibName, bundle: nil)
            self.collectioView?.register(nib, forCellWithReuseIdentifier: nibName)
            self.registeredCells.insert(nibName)
        }

        guard let cell = self.collectioView?.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as? CellType else {
            preconditionFailure("collectioView is nil or cell not registered")
        }

        return cell
    }

    public func dequeueReusableSupplementaryView<ViewType: UICollectionReusableView>(
        type: ViewType.Type,
        ofKind value: String,
        for indexPath: IndexPath
    ) -> ViewType {
        let identifier = String(describing: type)
        if registeredSupplementaries[value]?.contains(identifier) != true {
            self.collectioView?.register(ViewType.self, forSupplementaryViewOfKind: value, withReuseIdentifier: identifier)
            if registeredSupplementaries[value] == nil {
                registeredSupplementaries[value] = []
            }
            self.registeredCells.insert(identifier)
        }
        let view = self.collectioView?.dequeueReusableSupplementaryView(ofKind: value, withReuseIdentifier: identifier, for: indexPath)
        guard let result = view as? ViewType else {
            preconditionFailure("collectioView is nil or SupplementaryView not registered")
        }
        return result
    }
}
