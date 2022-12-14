//
//  Bitfield.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct Bitfield {
    private(set) var data: [UInt8]

    var isEmpty: Bool {
        data.isEmpty
    }

    init(data: [UInt8] = []) {
        self.data = data
    }

    func hasPiece(index: Int) -> Bool {
       let byteIndex = index / 8
       let offset = index % 8
       return data[byteIndex] >> (7 - offset) & 1 != 0
   }

    // SetPiece sets a bit in the bitfield
    mutating func setPiece(index: UInt32) {
        let byteIndex = Int(index / 8)
        let offset = index % 8
        let latIndex = data.count - 1
        if latIndex < byteIndex {
            data.append(contentsOf: [UInt8](repeating: 0, count: byteIndex - latIndex))
        }
        data[byteIndex] |= 1 << (7 - offset)
    }
}
