//
//  PaginationCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

class PaginationCell: UICollectionViewCell {
    @IBOutlet var indicatorView: SpringIndicator!
    
    private var subscriber: AnyCancellable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.lineColor = UIColor(resource: .Tint.main)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicatorView.stop()
    }
    
    func configure(_ model: PaginationViewModel) {
        updateIndicator(isLast: model.isLast)
        subscriber = model.$isLast.sink { [weak self] value in
            self?.updateIndicator(isLast: value)
        }
    }
    
    private func updateIndicator(isLast: Bool) {
        if isLast {
            indicatorView.stop()
            indicatorView.isHidden = true
        } else {
            indicatorView.start()
            indicatorView.isHidden = false
        }
    }
}
