//
//  TorrentData.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentData {
    let announce: String
    let infoHash: [UInt8]
    let pieceHashes: [[UInt8]]
    let pieceLength: Int
    let content: TorrentContent

    func calculateBoundsForPiece(index: Int) -> (begin: Int, end: Int) {
        let begin = index * pieceLength
        var end = begin + pieceLength
        if end > content.length {
            end = content.length
        }
        return (begin, end)
    }

    func calculatePieceSize(index: Int) -> Int {
        let (begin, end) = calculateBoundsForPiece(index: index)
        return end - begin
    }

    func getPieceHashesBounds(for file: TorrentFile) -> (begin: Int, end: Int)? {
        guard let index = content.files.firstIndex(of: file) else { return nil }
        var begin = 0
        if index != 0 {
            begin = content.files[0..<index].reduce(0, { $0 + $1.calculatePiecesCount(with: pieceLength) })
        }
        let end = begin + content.files[index].calculatePiecesCount(with: pieceLength) - 1
        return (begin, end)
    }
}

extension TorrentData: BencodeDecodable {
    init?(from value: BencodeValue) {
        guard
            let announce = value["announce"]?.text,
            let info = value["info"],
            let infoSlice = info.slice,
            let piecesSlice = info["pieces"]?.slice,
            let pieceLength = info["piece length"]?.number,
            let content = TorrentContent(from: info)
        else {
            return nil
        }

        self.announce = announce
        self.pieceLength = pieceLength
        self.infoHash = Data(infoSlice).sha1()
        self.content = content

        self.pieceHashes = (0..<piecesSlice.count/20).map {
            let start = $0 * 20
            let end = ($0 + 1) * 20
            return Array(piecesSlice[start..<end])
        }
    }
}

extension TorrentData {
    func buildTrackerUrl() -> URL? {
        let params = [
            "info_hash=\(infoHash.asString())",
            "peer_id=\(Constants.peerID)",
            "port=\(Constants.port)",
            "uploaded=0",
            "downloaded=0",
            "compact=1",
            "left=\(content.length)"
        ].joined(separator: "&")
        return URL(string: "\(announce)?\(params)")
    }
}
