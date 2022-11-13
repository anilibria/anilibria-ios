//
//  TorrentFile.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentFile: Hashable {
    let name: String
    let path: String
    let length: Int

    func calculatePiecesCount(with pieceLength: Int) -> Int {
        Int(ceil(Double(length) / Double(pieceLength)))
    }
}
