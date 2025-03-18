//
//  RelatedSeriesView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class RelatedSeriesView: UIView {
    @IBOutlet private var button: UIButton!
    @IBOutlet private var titleLabel: UILabel!

    private var handler: Action<Series>?

    private var series: Series?

    func setTap(handler: Action<Series>?) {
        self.handler = handler
    }

    func configure(index: Int, series: Series, selected: Bool) {
        self.series = series
        titleLabel.text = "\(index + 1). \(series.name?.main ?? "")"
        if selected {
            titleLabel.textColor = UIColor(resource: .Buttons.selected)
            button.isUserInteractionEnabled = false
        } else {
            titleLabel.textColor = UIColor(resource: .Text.main)
            button.isUserInteractionEnabled = true
        }
    }

    @IBAction func tapAction(_ sender: Any) {
        if let series {
            self.handler?(series)
        }
    }
}
