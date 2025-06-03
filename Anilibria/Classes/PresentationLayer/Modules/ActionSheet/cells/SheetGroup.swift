//
//  SheetGroup.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

public class SheetGroup: NSObject {
    let title: String?
    let icon: UIImage?
    let isExpandable: Bool

    init(title: String? = nil, icon: UIImage? = nil, isExpandable: Bool = false) {
        self.title = title
        self.icon = icon
        self.isExpandable = isExpandable
    }
}

public struct SheetSelector {
    private var action : () -> Bool

    init(_ action: @escaping () -> Bool) {
        self.action = action
    }

    func select() -> Bool {
        action()
    }
}
