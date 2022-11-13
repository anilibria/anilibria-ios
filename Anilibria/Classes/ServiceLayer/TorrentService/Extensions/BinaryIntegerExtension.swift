//
//  BinaryIntegerExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

extension BinaryInteger {
    var bytes: [UInt8] {
        let capacity = MemoryLayout<Self>.size
        var mutableValue = self
        return withUnsafePointer(to: &mutableValue) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: capacity) {
                return Array(UnsafeBufferPointer(start: $0, count: capacity))
            }
        }
    }

    init?<C: Collection<UInt8>>(_ collection: C) {
        let littleEndianBytes = Array(collection)
        guard littleEndianBytes.count == MemoryLayout<Self>.size else { return nil }
        self = littleEndianBytes.withUnsafeBytes { $0.load(as: Self.self) }
    }
}
