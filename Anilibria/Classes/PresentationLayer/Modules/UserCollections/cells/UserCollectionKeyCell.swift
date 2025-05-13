//
//  UserCollectionKeyCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class UserCollectionKeyCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backView: UIView!

    private var bag: AnyCancellable?

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.font(ofSize: 15, weight: .regular)
        backView.smoothCorners(with: backView.bounds.height / 2)
    }

    func configure(_ item: UserCollectionKeyViewModel) {
        titleLabel.text = item.key.title
        set(selected: item.isSelected, animated: false)
        bag = item.$isSelected.dropFirst().sink(receiveValue: { [weak self] value in
            self?.set(selected: value, animated: true)
        })
    }

    func set(selected: Bool, animated: Bool) {
        func apply() {
            if selected {
                backView.backgroundColor = UIColor(resource: .Buttons.selected)
                titleLabel.textColor = UIColor(resource: .Text.monoLight)
            } else {
                backView.backgroundColor = UIColor(resource: .Buttons.unselected)
                titleLabel.textColor = UIColor(resource: .Text.main)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.3) {
                apply()
            }
        } else {
            apply()
        }
    }
}
