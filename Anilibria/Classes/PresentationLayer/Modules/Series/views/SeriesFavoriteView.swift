//
//  SeriesFavoriteView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class SeriesFavoriteView: UIView {
    @IBOutlet var button: UIButton!
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

        shimmerView.backgroundColor = .Tint.shimmer
        shimmerView.shimmerColor = .Surfaces.base
        isLoading = false
        button.accessibilityIdentifier = "series.favorite"
        button.accessibilityLabel = L10n.Common.Collections.favorites
        set(favorite: false)
    }

    func set(favorite: Bool) {
        var configuration: UIButton.Configuration
        if #available(iOS 26.0, *) {
            configuration = favorite ? .prominentGlass() : .glass()
        } else {
            configuration = favorite ? .filled() : .tinted()
        }
        configuration.image = UIImage(systemName: favorite ? "star.fill" : "star")
        configuration.preferredSymbolConfigurationForImage = .init(textStyle: .body)
        button.configuration = configuration
        button.accessibilityTraits = favorite ? [.button, .selected] : [.button]
    }
}
