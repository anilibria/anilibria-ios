//
//  ChoiceHaderView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.05.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
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
        self.addSubview(titleLabel)
        titleLabel.constraintEdgesToSuperview(.init(left: 16))
        titleLabel.font = UIFont.font(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor.white
    }
}
