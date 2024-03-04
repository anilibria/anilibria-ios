//
//  PassThroughView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.03.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

open class PassThroughView: UIView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view != self { return view }
        return nil
    }
}

open class PassThroughWindow: UIWindow {
    var bag: Any?
    weak var targetWindow: UIWindow? {
        didSet {
            bag = targetWindow?.layer.observe(\.bounds, changeHandler: { [weak self] layer, _ in
                self?.frame = layer.bounds
            })
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view != self {
            return view
        }

        if #available(iOS 13.4, *) {
            if event?.type == .scroll {
                return targetWindow?.hitTest(point, with: event)
            }
        }
        return nil
    }

    open override var next: UIResponder? {
        super.next
    }
}
