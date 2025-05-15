//
//  SheetAdapterSectionFactory.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

enum SheetAdapterSectionFactory {
    static func create(for items: [ChoiceGroup], select: ((SheetSelector) -> Void)?) -> [any SectionAdapterProtocol] {
        items.map { ChoiceCellSectionAdapter($0, select: select) }
    }
}
