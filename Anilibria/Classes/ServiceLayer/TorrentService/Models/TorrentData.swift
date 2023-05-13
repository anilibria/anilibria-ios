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

    func calculateBoundsForPiece(index: Int, file: TorrentFile) -> (begin: Int, end: Int) {
        let fileBounds = file.position.hashesBounds
        let updatedIndex = index - fileBounds.begin

        var begin = updatedIndex * pieceLength
        var end = begin + pieceLength
        if index == pieceHashes.count - 1 {
            if end > file.length {
                end = file.length
            }
            if begin > file.length {
                begin = file.length
            }
        }
        
        assert(begin <= end, "Wrong bounds For piece")
        return (begin, end)
    }

    func calculatePieceSize(index: Int, file: TorrentFile) -> Int {
        if content.files.last == file && index == pieceHashes.count - 1 {
            return pieceLength - file.position.dataInsets.end
        }
        return pieceLength
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
            let content = TorrentContent(from: info, pieceLength: pieceLength)
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
