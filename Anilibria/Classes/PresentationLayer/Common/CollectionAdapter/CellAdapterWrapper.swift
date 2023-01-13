//
//  CellAdapterWrapper.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct CellAdapterWrapper: Hashable {
    let item: any CellAdapterProtocol

    func hash(into hasher: inout Hasher) {
        hasher.combine(item)
    }

    static func == (lhs: CellAdapterWrapper, rhs: CellAdapterWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
