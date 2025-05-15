//
//  SkipContainerView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class SkipContainerView: UIStackView {
    @IBOutlet var skipButton: RippleButton!
    @IBOutlet var watchButton: RippleButton!

    private weak var viewModel: SkipViewModel?
    private var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSkip()
    }

    private func setupSkip() {
        func applyStyle(to button: RippleButton) {
            button.smoothCorners(with: button.bounds.height / 2)
            button.titleLabel?.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
            button.setTitleColor(UIColor(resource: .Text.monoLight), for: .normal)
            button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            button.layer.borderColor = button.backgroundColor?.cgColor
            button.layer.borderWidth = 1
        }

        applyStyle(to: skipButton)
        applyStyle(to: watchButton)

        skipButton.setTitle(L10n.Buttons.skip, for: .normal)
        watchButton.setTitle(L10n.Buttons.watch, for: .normal)
    }

    func configure(with viewModel: SkipViewModel) {
        self.viewModel = viewModel

        viewModel.$canSkip.sink { [weak self] canSkip in
            self?.isHidden = !canSkip
        }.store(in: &cancellables)

        viewModel.$autoSkipTimeLeft.sink { [weak self] timeLeft in
            guard let self else { return }
            UIView.performWithoutAnimation {
                if timeLeft > 0 {
                    self.skipButton.setTitle("\(L10n.Buttons.skip)(\(timeLeft))", for: .normal)
                } else {
                    self.skipButton.setTitle(L10n.Buttons.skip, for: .normal)
                }
                self.skipButton.layoutIfNeeded()
            }
        }.store(in: &cancellables)
    }

    @IBAction func skipDidTap() {
        viewModel?.skip()
    }

    @IBAction func watchDidTap() {
        viewModel?.clearCurrentSkipRange()
    }
}
