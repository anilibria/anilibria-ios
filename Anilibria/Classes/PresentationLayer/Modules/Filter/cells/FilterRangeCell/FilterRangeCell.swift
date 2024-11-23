//
//  FilterRangeCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class FilterRangeCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueBackView: UIView!
    @IBOutlet weak var rangeView: RangeView!
    
    private var bag = Set<AnyCancellable>()

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor(resource: .Text.secondary)
        valueBackView.clipsToBounds = true
        valueBackView.layer.cornerRadius = 8
    }

    func configure(with model: FilterRangeItem) {
        bag.removeAll()
        titleLabel.text = model.title

        rangeView.set(
            maxIndex: model.itemsCount - 1,
            selectedMin: model.selectedMinIndex,
            selectedMax: model.selectedMaxIndex
        )

        Publishers.CombineLatest(
            rangeView.$selectedMin,
            rangeView.$selectedMax
        ).dropFirst().sink { [weak self] (min, max) in
            model.selectedMinIndex = min
            model.selectedMaxIndex = max
            self?.valueLabel.text = model.displayValue
            self?.apply(selected: model.isSelected)
            model.update()
        }.store(in: &bag)

        valueLabel.text = model.displayValue
        apply(selected: model.isSelected)
    }

    private func apply(selected: Bool) {
        if selected {
            valueLabel.textColor = UIColor(resource: .Text.monoLight)
            valueBackView.backgroundColor = UIColor(resource: .Buttons.selected)
        } else {
            valueLabel.textColor = UIColor(resource: .Text.main)
            valueBackView.backgroundColor = UIColor(resource: .Buttons.unselected)
        }
    }
}
