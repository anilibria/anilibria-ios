//
//  RewindView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class RewindView: CircleView {
    @IBOutlet var titleLabel: UILabel!
    private var tapHandler: Action<Double>?

    private var time: Double = 0

    func set(time: Double) {
        self.time = time
        self.titleLabel.text = "\(Int(abs(time)))"
    }

    func setDidTap(_ action: Action<Double>?) {
        self.tapHandler = action
    }

    @IBAction func tapAction(_ sender: Any) {
        self.tapHandler?(time)
    }
}
