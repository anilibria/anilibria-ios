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

    private weak var refreshActivity: ActivityDisposable?

    // MARK: - Properties

    public private(set) var refreshControl: RefreshIndicator?

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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateRefreshControlRect()
    }

    // MARK: - Refresh

    public func addRefreshControl(color: UIColor = MainTheme.shared.black) {
        if self.refreshControl != nil {
            return
        }
        self.collectionView.alwaysBounceVertical = true
        self.refreshControl = RefreshIndicator(style: .prominent)
        self.refreshControl?.indicator.lineColor = color
        self.collectionView.addSubview(self.refreshControl!)
        self.refreshControl?.addTarget(self,
                                       action: #selector(self.refresh),
                                       for: .valueChanged)
    }

    public func removeRefreshControl() {
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }

    public func updateRefreshControlRect() {
        self.refreshControl?.center.x = self.collectionView.bounds.width / 2
    }

    public func isRefreshing() -> Bool {
        return self.refreshControl?.isRefreshing ?? false
    }

    @objc
    public func refresh() {
        // override me
    }

    @objc
    private func rotated() {
        self.collectionView.reloadData()
    }

    // MARK: - Methods

    public func reload(sections: [any SectionAdapterProtocol], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.adapter.reload(content: .init(sections), animated: animated, completion: completion)
    }

    public func append(sections: [any SectionAdapterProtocol], animated: Bool = true, completion: (() -> Void)? = nil) {
        self.adapter.append(content: .init(sections), animated: animated, completion: completion)
    }

}

extension BaseCollectionViewController: RefreshBehavior {
    func showRefreshIndicator() -> ActivityDisposable? {
        if self.refreshActivity?.isDisposed == false {
            return self.refreshActivity
        }
        if self.isRefreshing() == false {
            self.refreshControl?.startRefreshing()
        }
        return self.createActivity()
    }

    private func createActivity() -> ActivityDisposable? {
        let activity = ActivityHolder { [weak self] in
            self?.refreshControl?.endRefreshing()
        }

        self.refreshActivity = activity
        return activity
    }
}

class InfinityCollectionViewController: BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewDelegate = self
    }

    public func loadMore() {
        // override me
    }
}

// MARK: - UIScrollViewDelegate

extension InfinityCollectionViewController: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if distance < 200 {
            self.loadMore()
        }
    }
}
