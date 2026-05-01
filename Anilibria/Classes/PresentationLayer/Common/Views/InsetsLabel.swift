//
//  InsetsLabel.swift
//  AniLiberty
//
//  Created by Ivan Morozov on 17.04.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import UIKit

public final class InsetsLabel: UILabel {
    public var insets: UIEdgeInsets = .zero

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
}
