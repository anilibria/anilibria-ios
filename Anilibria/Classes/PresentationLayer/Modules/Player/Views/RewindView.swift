//
//  RewindView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class RewindView: UIView {
    @IBOutlet var titleLabel: UILabel!

    private let timeFormatter = FormatterFactory.time.create()

    override func awakeFromNib() {
        super.awakeFromNib()
        smoothCorners(with: bounds.height / 2)
        backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        layer.borderColor = backgroundColor?.cgColor
        layer.borderWidth = 1

        titleLabel.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(resource: .Text.monoLight)
    }

    func set(time: Double) {
        let text = timeFormatter.string(from: time) ?? ""
        if time >= 0 {
            titleLabel.text = "+\(text)"
        } else {
            titleLabel.text = "-\(text)"
        }
    }
}
