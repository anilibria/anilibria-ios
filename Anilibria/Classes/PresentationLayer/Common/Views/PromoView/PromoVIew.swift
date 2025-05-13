//
//  PromoVIew.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

final class PromoView: LoadableView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var adLabel: UILabel!
    @IBOutlet var adView: BorderedView!
    @IBOutlet var adInfo: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var contentView: UIView!
    private var viewModel: PromoViewModel?
    private var workItem: DispatchWorkItem?

    private lazy var rippleManager: RippleManager = { [unowned self] in
        RippleManager(attatch: contentView)
    }()

    override func setupNib() {
        super.setupNib()
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        leftSwipe.direction = .left
        self.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        rightSwipe.direction = .right
        self.addGestureRecognizer(rightSwipe)
        rippleManager.rippleColor = UIColor(resource: .Tint.main)
        adView.cornerRadius = 8
        adView.borderColor = UIColor(resource: .Text.monoLight)
        adView.borderThickness = 1
        adLabel.text = L10n.Common.ad
        contentView.smoothCorners(with: 8)
    }

    func configure(with viewModel: PromoViewModel) {
        self.viewModel = viewModel
        pageControl.numberOfPages = viewModel.items.count
        apply(viewModel.selectedIndex, animated: false)
    }

    private func changeToNext() {
        guard let viewModel else { return }
        var next = viewModel.selectedIndex + 1
        if next >= viewModel.items.count {
            next = 0
        }
        apply(next, animated: true, forward: true)
    }

    private func changeToPrevious() {
        guard let viewModel else { return }
        var next = viewModel.selectedIndex - 1
        if next < 0 {
            next = viewModel.items.count - 1
        }
        apply(next, animated: true, forward: false)
    }

    @objc private func swipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left: changeToNext()
        case .right: changeToPrevious()
        default: break
        }
    }

    private func apply(_ index: Int, animated: Bool, forward: Bool = true) {
        guard let model = viewModel?.items[safe: index] else {
            return
        }
        infoLabel.text = model.info
        imageView.image = nil
        imageView.cancelDownloadTask()
        imageView.setImage(from: model.image)
        adView.isHidden = true
        adInfo.isHidden = true

        switch model.content {
        case .ad(let ad):
            titleLabel.text = ad.title
            adView.isHidden = false
            adInfo.isHidden = false
            adInfo.text = ad.info
        case .release(let series):
            titleLabel.text = series.name?.main
        case .promo(let item):
            titleLabel.text = item.title
        case nil:
            break
        }

        if animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            if forward {
                transition.subtype = .fromRight
            } else {
                transition.subtype = .fromLeft
            }
            transition.timingFunction = .init(name: .easeInEaseOut)
            contentView.superview?.layer.add(transition, forKey: "transition")
        }
        pageControl.currentPage = index
        viewModel?.selectedIndex = index
        workItem?.cancel()
        if (viewModel?.items.count ?? 0) > 1 {
            workItem = DispatchWorkItem { [weak self] in
                self?.changeToNext()
            }
            if let workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: workItem)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.rippleManager.touchesBegan(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.rippleManager.touchesEnded()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.rippleManager.touchesEnded()
    }
}
