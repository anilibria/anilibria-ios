//
//  PieceWork.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

class PieceWork {
    let index: Int
    let hash: [UInt8]
    let length: Int

    var buffer: [UInt8]
    var downloaded: Int = 0

    init(index: Int, hash: [UInt8], length: Int) {
        self.index = index
        self.hash = hash
        self.length = length
        self.buffer = [UInt8](repeating: 0, count: length)

    }

    func reset() {
        downloaded = 0
    }

    func checkIntegrity() -> Bool {
        hash == Data(buffer).sha1()
    }
}
