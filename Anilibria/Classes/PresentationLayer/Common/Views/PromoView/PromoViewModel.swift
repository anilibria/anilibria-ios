//
//  PromoViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public final class PromoViewModel: Hashable {
    var selectedIndex: Int = 0
    let items: [PromoItem]
    let selectionHandler: (PromoItem) -> Void

    init(items: [PromoItem], select: @escaping (PromoItem) -> Void) {
        self.items = items
        self.selectionHandler = select
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(items)
    }

    func select() {
        if let item = items[safe: selectedIndex] {
            selectionHandler(item)
        }
    }

    public static func == (lhs: PromoViewModel, rhs: PromoViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
