//
//  FilterTitleView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class FilterTitleView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!

    func configure(_ text: String) {
        self.titleLabel.text = text
    }
}
