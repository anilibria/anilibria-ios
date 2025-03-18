//
//  ChoiceHaderView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

class ChoiceHaderView: UICollectionReusableView {
    let titleLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.constraintEdgesToSuperview(
            .init(top: 16, left: 16, bottom: 0, right: 16)
        )
        titleLabel.font = UIFont.font(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor.white
    }
}
