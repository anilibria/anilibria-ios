//
//  BaseCollectionViewController.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import UIKit

class BaseCollectionViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!

    // MARK: - Properties

    var defaultBottomInset: CGFloat = 40

    public lazy var adapter = CollectionViewAdapter(collectionView: collectionView)

    public var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return self.adapter.scrollViewDelegate
        }
        set {
            self.adapter.scrollViewDelegate = newValue
        }
    }
    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentInset.bottom = self.defaultBottomInset
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateRefreshControlRect()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Methods

    public func set(sections: [any SectionAdapterProtocol], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.adapter.set(sections: sections, animated: animated, completion: completion)
    }
}
