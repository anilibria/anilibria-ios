//
//  PromoCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class PromoCell: UICollectionViewCell {
    @IBOutlet var view: PromoView!

    func configure(_ model: PromoViewModel) {
        view.configure(with: model)
    }
}
