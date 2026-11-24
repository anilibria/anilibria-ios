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
        indicatorView.lineColor = .Tint.main
        indicatorView.start()
        indicatorView.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicatorView.stop()
        indicatorView.start()
    }
}
