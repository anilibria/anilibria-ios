//
//  UIInterfaceOrientationExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 14.01.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit

extension UIInterfaceOrientation {
    static func from(mask: UIInterfaceOrientationMask) -> UIInterfaceOrientation {
        switch mask {
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
}
