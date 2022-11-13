//
//  Handshake.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct Handshake {
    static let head: [UInt8] = [0x13] + "BitTorrent protocol".utf8 + [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]
    let infoHash: [UInt8]
    let peerID: [UInt8]

    func makeData() -> Data {
        Data(Self.head + infoHash + peerID)
    }
}

extension Handshake {
    init(_ torrent: TorrentData) {
        self.infoHash = torrent.infoHash
        self.peerID = Array(Constants.peerID.utf8)
    }
}

extension Handshake {
    static func make(from data: Data) -> (Handshake?, leftBytes: [UInt8]) {
        let buffer = [UInt8](data)
        let headEnd = Self.head.count
        guard buffer.count >= headEnd + 40 else { return (nil, []) }
        let infoHashEnd = headEnd + 20
        let peerIDEnd = infoHashEnd + 20

        let result = Handshake(infoHash: Array(buffer[headEnd..<infoHashEnd]),
                               peerID: Array(buffer[infoHashEnd..<peerIDEnd]))

        if buffer.count > headEnd + 40 {
           return (result, Array(buffer[peerIDEnd..<buffer.count]))
        }

        return (result, [])
    }
}
