//
//  MessageID.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

enum MessageID: UInt8, CustomDebugStringConvertible {
    case choke
    case unchoke
    case interested
    case notInterested
    case have
    case bitfield
    case request
    case piece
    case cancel
    case port

    var debugDescription: String {
        switch self {
        case .choke: return "choke"
        case .unchoke: return "unchoke"
        case .interested: return "interested"
        case .notInterested: return "notInterested"
        case .have: return "have"
        case .bitfield: return "bitfield"
        case .request: return "request"
        case .piece: return "piece"
        case .cancel: return "cancel"
        case .port: return "port"
        }
    }

    var length: UInt32? {
        switch self {
        case .choke, .unchoke, .interested, .notInterested:
            return 1
        case .have:
            return 5
        case .request, .cancel:
            return 13
        case .port:
            return 3
        case .piece, .bitfield:
            return nil
        }
    }

    func validate(length: UInt32) -> Bool {
        if let fixedLength = self.length {
            return length == fixedLength
        }

        return length > 0
    }
}
