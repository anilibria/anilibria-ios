//
//  TorrentContent.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentContent: Codable {
    let length: Int
    let files: [TorrentFile]

    init(files: [TorrentFile]) {
        self.files = files
        self.length = files.reduce(0, { $0 + $1.length })
    }
}

extension TorrentContent {
    init?(from info: BencodeValue, pieceLength: Int) {
        guard let name = info["name"]?.text else {
            return nil
        }

        let length = info["length"]?.number
        var offset = 0
        let files = info["files"]?.list?.enumerated().compactMap({ (index, value) -> TorrentFile? in
            guard
                let length = value["length"]?.number,
                var pathArray = value["path"]?.list?.compactMap(\.text),
                !pathArray.isEmpty
            else {
                return nil
            }
            defer { offset += length }
            let name = pathArray.removeLast()
            let path = pathArray.joined(separator: "/")
            let position = Self.getPieceHashesBounds(for: index, length: length, offset: offset, pieceLength: pieceLength)
            return TorrentFile(
                name: name,
                path: path,
                length: length,
                position: position
            )
        }) ?? []

        if !files.isEmpty {
            self.init(files: files)
        } else if let length = length {
            let position = Self.getPieceHashesBounds(for: 0, length: length, offset: 0, pieceLength: pieceLength)
            self.init(files: [
                TorrentFile(
                    name: name,
                    path: "",
                    length: length,
                    position: position
                )
            ])
        } else {
            return nil
        }
    }

    private static func getPieceHashesBounds(for index: Int, length: Int, offset: Int, pieceLength: Int) -> DataPosition {
        var begin = 0
        var beginInset = 0
        if index != 0 {
            begin = calculateFloorPiecesCount(offset, pieceLength: pieceLength)
            beginInset = max(offset - begin * pieceLength, 0)
        }
        let contentPicesCount = calculateCeilPiecesCount(length + beginInset, pieceLength: pieceLength)
        let end = begin + contentPicesCount - 1
        let endInset = contentPicesCount * pieceLength - length - beginInset
        assert(endInset >= 0, "Wrong end inset")

        return DataPosition(
            hashesBounds: .init(begin: begin, end: end),
            dataInsets: .init(begin: beginInset, end: endInset)
        )
    }

    private static func calculateFloorPiecesCount(_ length: Int, pieceLength: Int) -> Int {
        Int(floor(calculatePiecesCount(length: length, pieceLength: pieceLength)))
    }

    private static func calculateCeilPiecesCount(_ length: Int, pieceLength: Int) -> Int {
        Int(ceil(calculatePiecesCount(length: length, pieceLength: pieceLength)))
    }

    private static func calculatePiecesCount(length: Int, pieceLength: Int) -> Double {
        Double(length) / Double(pieceLength)
    }
}
