//
//  PieceWork.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct PieceWork: Hashable, Codable, CustomDebugStringConvertible {
    let index: Int
    let hash: [UInt8]
    let length: Int

    var buffer: [UInt8]
    var downloaded: Int = 0

    enum CodingKeys: CodingKey {
        case index
        case hash
        case length
        case buffer
        case downloaded
    }

    init(index: Int, hash: [UInt8], length: Int) {
        self.index = index
        self.hash = hash
        self.length = length
        self.buffer = [UInt8](repeating: 0, count: length)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.index = try container.decode(Int.self, forKey: .index)
        self.hash = try container.decode([UInt8].self, forKey: .hash)
        self.length = try container.decode(Int.self, forKey: .length)
        self.buffer = [UInt8](repeating: 0, count: length)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.index, forKey: .index)
        try container.encode(self.hash, forKey: .hash)
        try container.encode(self.length, forKey: .length)
    }

    mutating func reset() {
        downloaded = 0
    }

    func checkIntegrity() -> Bool {
        hash == Data(buffer).sha1()
    }

    var debugDescription: String {
        return "\(index)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }

    static func == (lhs: PieceWork, rhs: PieceWork) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
