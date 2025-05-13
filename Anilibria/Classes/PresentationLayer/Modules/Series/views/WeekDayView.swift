//
//  WeekDayView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class WeekDayView: CircleView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(ofSize: 12, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private var subscriber: AnyCancellable?
    
    public private(set) var day: WeekDay?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        borderColor = UIColor(resource: .Tint.separator)
        borderThickness = 1
        backgroundColor = .clear
        
        titleLabel.constraintEdgesToSuperview(.init(top: 10, left: 4, bottom: 10, right: 4))
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
    }
    
    func configure(_ weekDay: WeekDay) {
        self.day = weekDay
        titleLabel.text = weekDay.shortName
        
        subscriber = Language.languageChanged.sink { [weak self] in
            self?.titleLabel.text = weekDay.shortName
        }
    }

    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                self.backgroundColor = UIColor(resource: .Buttons.selected)
                self.titleLabel.textColor = UIColor(resource: .Text.monoLight)
                self.borderThickness = 0
            } else {
                self.backgroundColor = .clear
                self.titleLabel.textColor = UIColor(resource: .Text.secondary)
                self.borderThickness = 1
            }
        }
    }
}
