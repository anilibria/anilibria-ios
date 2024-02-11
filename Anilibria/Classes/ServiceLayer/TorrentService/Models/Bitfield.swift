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
    
    private func make<T: FixedWidthInteger>(index: T) -> (byteIndex: Int, offset: Int) {
        let index = Int(index)
        return (index / 8, index % 8)
    }
    
    private mutating func updateDataCapacityIfNeeded(_ byteIndex: Int) {
        let lastIndex = data.count - 1
        if lastIndex < byteIndex {
            data.append(contentsOf: [UInt8](repeating: 0, count: byteIndex - lastIndex))
        }
    }

    func hasPiece<T: FixedWidthInteger>(index: T) -> Bool {
        let value = make(index: index)
        return data[value.byteIndex] >> (7 - value.offset) & 1 != 0
    }

    // set a bit in the bitfield
    mutating func setPiece<T: FixedWidthInteger>(index: T) {
        let value = make(index: index)
        updateDataCapacityIfNeeded(value.byteIndex)
        data[value.byteIndex] |= 1 << (7 - value.offset)
    }
    
    // remove a bit in the bitfield
    mutating func removePiece<T: FixedWidthInteger>(index: T) {
        let value = make(index: index)
        updateDataCapacityIfNeeded(value.byteIndex)
        data[value.byteIndex] &= ~(1 << (7 - value.offset))
    }
}

extension Bitfield {
    func intersects(_ bitfield: Bitfield) -> Bool {
        if data.count <= bitfield.data.count {
            return data.enumerated().contains(where: { item in
                bitfield.data[item.offset] & item.element > 0
            })
        }
        return bitfield.intersects(self)
    }

    func intersection(_ bitfield: Bitfield) -> Bitfield {
        if data.count <= bitfield.data.count {
            var result = self
            data.enumerated().forEach { item in
                result.data[item.offset] = bitfield.data[item.offset] & item.element
            }
            return result
        }
        return bitfield.intersection(self)
    }

    func getFirstIndex() -> Int? {
        if isEmpty {
            return nil
        }

        guard let byteIndex = data.firstIndex(where: { $0 > 0 }) else { return nil }
        var offset = 0
        while offset < 8 {
            if data[byteIndex] >> (7 - offset) & 1 != 0 {
                break
            }
            offset += 1
        }

        if offset > 7 { return nil }
        return byteIndex * 8 + offset
    }
}
