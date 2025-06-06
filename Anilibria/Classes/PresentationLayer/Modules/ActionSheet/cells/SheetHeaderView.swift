//
//  SheetHeaderView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

class SheetHeaderView: UICollectionReusableView {
    private let contentView: UIStackView = UIStackView()
    private let titleLabel: UILabel = UILabel()
    private let selectedValueLabel: UILabel = UILabel()
    private let chevronView: UIImageView = UIImageView()

    var tapAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.constraintEdgesToSuperview(
            .init(top: 8, left: 16, bottom: 8, right: 16)
        )
        contentView.axis = .horizontal
        contentView.spacing = 8
        contentView.alignment = .center

        chevronView.tintColor = .Text.monoLight
        chevronView.image = .System.Chevrone.right
        chevronView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        chevronView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        chevronView.isHidden = true
        chevronView.contentMode = .scaleAspectFit
        contentView.addArrangedSubview(chevronView)

        titleLabel.font = UIFont.font(ofSize: 14, weight: .bold)
        titleLabel.textColor = .Text.monoLight
        contentView.addArrangedSubview(titleLabel)

        selectedValueLabel.font = UIFont.font(ofSize: 12, weight: .semibold)
        selectedValueLabel.textColor = .Text.monoLight
        selectedValueLabel.setContentHuggingPriority(.required, for: .horizontal)
        selectedValueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        selectedValueLabel.isHidden = true
        contentView.addArrangedSubview(selectedValueLabel)
        contentView.isUserInteractionEnabled = false
        self.isExclusiveTouch = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        tapAction?()
    }

    func set(title: String?) {
        titleLabel.text = title
    }

    func set(value: String?) {
        selectedValueLabel.text = value
    }

    func setValue(hidden: Bool) {
        selectedValueLabel.isHidden = hidden
    }

    func set(expanded: Bool?, animated: Bool) {
        guard let expanded else {
            chevronView.isHidden = true
            return
        }
        chevronView.isHidden = false

        func apply() {
            if expanded {
                chevronView.transform = CGAffineTransform(rotationAngle: .pi/2)
            } else {
                chevronView.transform = .identity
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2) {
                apply()
            }
        } else {
            apply()
        }
    }
}
