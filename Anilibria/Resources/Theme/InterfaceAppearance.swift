//
//  InterfaceAppearance.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public enum InterfaceAppearance: Codable, CaseIterable {
    private static let key: String = "InterfaceAppearance_KEY"

    case light
    case dark
    case system

    var title: String {
        switch self {
        case .light:
            return L10n.Common.Appearance.light
        case .dark:
            return L10n.Common.Appearance.dark
        case .system:
            return L10n.Common.Appearance.system
        }
    }

    static var current: InterfaceAppearance {
        UserDefaults.standard[Self.key] ?? .system
    }

    func apply() {
        let style: UIUserInterfaceStyle
        switch self {
        case .light: style = .light
        case .dark: style = .dark
        case .system: style = .unspecified
        }
        MainAppCoordinator.shared.window?.overrideUserInterfaceStyle = style
    }

    func save() {
        UserDefaults.standard[Self.key] = self
    }
}
