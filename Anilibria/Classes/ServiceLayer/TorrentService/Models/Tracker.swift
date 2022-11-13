//
//  Tracker.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct Tracker {
    let interval: Int
    let peers: [Peer]
}

extension Tracker: BencodeDecodable {
    init?(from value: BencodeValue) {
        guard
            let interval = value["interval"]?.number,
            let peers = value["peers"]
        else {
            return nil
        }

        if let list = peers.list {
            self.peers = list.compactMap { peer -> Peer? in
                guard let ip = peer["ip"]?.text, let port = peer["port"]?.number else { return nil }
                return Peer(ip: ip, port: UInt16(port))
            }
        } else if let slice = peers.slice {
            self.peers = (0..<slice.count/6).compactMap {
                let start = $0 * 6
                let end = ($0 + 1) * 6
                let peer = slice[start..<end]
                let ip = peer.prefix(4).map { "\($0)" }.joined(separator: ".")
                guard let port = UInt16(peer.suffix(2))?.byteSwapped else {
                    return nil
                }
                return Peer(ip: ip, port: port)
            }
        } else {
            return nil
        }

        self.interval = interval
    }
}
