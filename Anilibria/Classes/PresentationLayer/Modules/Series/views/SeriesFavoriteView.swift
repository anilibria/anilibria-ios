//
//  SeriesFavoriteView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class SeriesFavoriteView: UIView {
    @IBOutlet var starView: UIImageView!
    @IBOutlet var button: RippleButton!
    @IBOutlet var shimmerView: ShimmerView!

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                shimmerView.isHidden = false
                shimmerView.run()
            } else {
                shimmerView.isHidden = true
                shimmerView.stop()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        smoothCorners(with: 8)
        shimmerView.backgroundColor = UIColor(resource: .Tint.shimmer)
        shimmerView.shimmerColor = UIColor(resource: .Surfaces.base)
        isLoading = false
    }

    func set(favorite: Bool) {
        if favorite {
            backgroundColor = UIColor(resource: .Buttons.selected)
            starView.tintColor = UIColor(resource: .Text.monoLight)
        } else {
            backgroundColor = UIColor(resource: .Buttons.unselected)
            starView.tintColor = UIColor(resource: .Text.main)
        }
        fadeTransition()
    }
}
