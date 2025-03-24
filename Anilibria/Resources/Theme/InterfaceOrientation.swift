//
//  InterfaceOrientation.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public enum InterfaceOrientation: Codable, CaseIterable {
    private static let key: String = "InterfaceOrientation_KEY"

    case portrait
    case landscape
    case landscapeRight
    case system

    var title: String {
        switch self {
        case .portrait:
            return L10n.Common.Orientation.portrait
        case .landscape:
            return L10n.Common.Orientation.landscape + " ↺"
        case .landscapeRight:
            return L10n.Common.Orientation.landscape + " ↻"
        case .system:
            return L10n.Common.Orientation.system
        }
    }

    static var current: InterfaceOrientation {
        UserDefaults.standard[Self.key] ?? .system
    }

    var mask: UIInterfaceOrientationMask {
        switch self {
        case .portrait: return .portrait
        case .landscape: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .system: return .all
        }
    }

    func save() {
        UserDefaults.standard[Self.key] = self
    }
}
