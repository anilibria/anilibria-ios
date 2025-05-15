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
            .init(top: 16, left: 16, bottom: 0, right: 16)
        )
        contentView.axis = .horizontal
        contentView.spacing = 8
        contentView.alignment = .center

        titleLabel.font = UIFont.font(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor(resource: .Text.monoLight)
        contentView.addArrangedSubview(titleLabel)

        chevronView.tintColor = UIColor(resource: .Text.monoLight)
        chevronView.image = UIImage(systemName: "chevron.down")
        chevronView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        chevronView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        chevronView.isHidden = true
        contentView.addArrangedSubview(chevronView)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        tapAction?()
    }

    func set(title: String?) {
        titleLabel.text = title
    }

    func set(expanded: Bool?, animated: Bool) {
        guard let expanded else {
            chevronView.isHidden = true
            return
        }
        chevronView.isHidden = false

        func apply() {
            if expanded {
                chevronView.transform = CGAffineTransform(rotationAngle: .pi)
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
