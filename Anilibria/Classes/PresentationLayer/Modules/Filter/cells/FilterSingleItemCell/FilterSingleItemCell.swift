//
//  FilterSingleItemCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class FilterSingleItemCell: RippleViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var selectionLabel: UILabel!
    @IBOutlet private weak var selectionImageView: UIImageView!

    private var bag = Set<AnyCancellable>()

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .Text.secondary
        selectionView.clipsToBounds = true
        selectionView.layer.cornerRadius = 8
        selectionImageView.image = .System.Chevrone.down.withRenderingMode(.alwaysTemplate)
    }

    func configure(with model: FilterSingleItem) {
        bag.removeAll()
        titleLabel.text = model.title

        model.$isSelected.sink { [weak self] value in
            self?.apply(selected: value)
        }.store(in: &bag)

        model.$value.sink { [weak self] value in
            self?.selectionLabel.text = value
        }.store(in: &bag)
    }

    private func apply(selected: Bool) {
        if selected {
            let color = UIColor.Text.monoLight
            selectionLabel.textColor = color
            selectionImageView.tintColor = color
            selectionView.backgroundColor = .Buttons.selected
        } else {
            let color = UIColor.Text.main
            selectionLabel.textColor = color
            selectionImageView.tintColor = color
            selectionView.backgroundColor = .Buttons.unselected
        }
    }
}
