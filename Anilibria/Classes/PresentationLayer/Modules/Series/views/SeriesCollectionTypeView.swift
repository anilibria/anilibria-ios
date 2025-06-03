//
//  SeriesCollectionTypeView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class SeriesCollectionTypeView: UIView {
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var shimmerView: ShimmerView!

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                shimmerView.isHidden = false
                shimmerView.run()
            } else {
                shimmerView.isHidden = true
                shimmerView.stop()
            }
            fadeTransition()
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        smoothCorners(with: 8)
        shimmerView.backgroundColor = UIColor(resource: .Tint.shimmer)
        shimmerView.shimmerColor = UIColor(resource: .Surfaces.base)
        isLoading = false
        selectionImageView.image = UIImage(resource: .iconArrowDown).withRenderingMode(.alwaysTemplate)
    }

    func configure(with item: UserCollectionType?) {
        apply(selected: item != nil)
        selectionLabel.text = item?.localizedTitle ?? L10n.Common.Collections.addTo
        fadeTransition()
    }

    private func apply(selected: Bool) {
        if selected {
            let color = UIColor(resource: .Text.monoLight)
            selectionLabel.textColor = color
            selectionImageView.tintColor = color
            backgroundColor = UIColor(resource: .Buttons.selected)
        } else {
            let color = UIColor(resource: .Text.main)
            selectionLabel.textColor = color
            selectionImageView.tintColor = color
            backgroundColor = UIColor(resource: .Buttons.unselected)
        }
    }
}
