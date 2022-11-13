//
//  Bitfield.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct Bitfield {
    let length: Int
    private(set) var data: [UInt8]

    var isEmpty: Bool {
        data.isEmpty
    }

    init(length: Int = 0, data: [UInt8] = []) {
        self.length = length
        self.data = data
    }

    func hasPiece(index: Int) -> Bool {
       let byteIndex = index / 8
       let offset = index % 8
       return data[byteIndex] >> (7 - offset) & 1 != 0
   }

   // SetPiece sets a bit in the bitfield
    mutating func setPiece(index: UInt32) {
        let byteIndex = index / 8
        let offset = index % 8
        data[Int(byteIndex)] |= 1 << (7 - offset)
    }
}
