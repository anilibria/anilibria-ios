//
//  PieceWork.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

// private let formatter = ByteCountFormatter()

class PieceWork: CustomDebugStringConvertible {
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

    var debugDescription: String {
//        let d = formatter.string(for: downloaded) ?? "None"
//        let l = formatter.string(for: length) ?? "None"
//        return "\(index): \(d)/\(l) - \(Int(Double(downloaded)/Double(length) * 100))%"
        return "\(index)"
    }
}
