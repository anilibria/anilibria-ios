//
//  TorrentFile.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentFile: Codable, Hashable {
    let name: String
    let path: String
    let length: Int

    let position: DataPosition

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(path)
        hasher.combine(length)
    }

    static func == (lhs: TorrentFile, rhs: TorrentFile) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct DataPosition: Codable {
    struct Bounds: Codable {
        let begin: Int
        let end: Int
    }

    let hashesBounds: Bounds
    let dataInsets: Bounds
}

extension DataPosition {
    var boundsRange: ClosedRange<Int> {
        (hashesBounds.begin...hashesBounds.end)
    }
}
