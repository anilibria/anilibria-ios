//
//  UIScreenExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 15.08.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

public extension UIScreen {
    var interfaceOrientation: UIInterfaceOrientation {
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        switch (point.x, point.y) {
        case (0, 0):
            return .portrait
        case let (x, y) where x != 0 && y != 0:
            return .portraitUpsideDown
        case let (0, y) where y != 0:
            return .landscapeLeft
        case let (x, 0) where x != 0:
            return .landscapeRight
        default:
            return .unknown
        }
    }
}
