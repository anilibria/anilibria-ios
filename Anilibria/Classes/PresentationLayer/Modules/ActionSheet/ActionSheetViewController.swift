//
//  ActionSheetViewController.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - View Controller

final class ActionSheetViewController: BaseCollectionViewController {
    @IBOutlet var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var additionalStackView: UIStackView! {
        didSet {
            updateAdditionalView()
        }
    }

    var additionalView: UIView? {
        didSet {
            updateAdditionalView()
        }
    }

    var handler: ActionSheetEventHandler!
    private var bag: Any?

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.defaultBottomInset = 0
        super.viewDidLoad()
        self.addKeyboardObservers()
        self.view.backgroundColor = .clear
        self.handler.didLoad()

        self.bag = self.collectionView.observe(\UICollectionView.contentSize) { [weak self] _, _ in
            if let height = self?.collectionView.contentSize.height {
                self?.collectionHeightConstraint.constant = height
                UIView.animate(withDuration: 0.2) {
                    self?.view.layoutIfNeeded()
                }
            }
        }

        adapter.setLayout(type: SectionBackgroundCollectionViewCompositionalLayout.self) { layout in
            layout.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            layout.cornerRadius = 4
            layout.backgroundInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
            layout.configuration.interSectionSpacing = 16
        }
    }
    
    override func setupStrings() {
        super.setupStrings()
        backButton.setTitle(L10n.Buttons.done, for: .normal)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentingViewController {
            return presentingViewController.supportedInterfaceOrientations
        }
        return .all
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let presentingViewController {
            return presentingViewController.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateAdditionalView() {
        guard let additionalStackView else {
            return
        }
        additionalStackView.subviews.forEach {
            additionalStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if let additionalView {
            additionalStackView.addArrangedSubview(additionalView)
            additionalStackView.isHidden = false
        } else {
            additionalStackView.isHidden = true
        }
    }

    // MARK: - Actions

    @IBAction func backAction(_ sender: Any) {
        self.handler.back()
    }
}

extension ActionSheetViewController: ActionSheetViewBehavior {
    func set(items: [ChoiceGroup]) {
        let sections = SheetAdapterSectionFactory.create(for: items) { [weak self] item in
            self?.handler.select(item: item)
        }
        self.set(sections: sections)
    }
}
