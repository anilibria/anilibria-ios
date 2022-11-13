//
//  PeerMessage.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

class PeerMessage {
    let length: Int
    let id: MessageID
    private(set) var payload: [UInt8]

    var lackOfData: Bool {
        length > payload.count + 1
    }

    func makeData() -> Data {
        Data(UInt32(length).bigEndian.bytes + [id.rawValue] + payload)
    }

    func add(bytes: [UInt8]) -> [UInt8]? {
        let needed = length - 1 - payload.count
        self.payload.append(contentsOf: bytes.prefix(needed))
        let left = bytes.dropFirst(needed)
        if !left.isEmpty {
            return Array(left)
        }
        return nil
    }

    init(length: Int, id: MessageID, payload: [UInt8]) {
        self.length = length
        self.id = id
        self.payload = payload
    }

    convenience init(id: MessageID, payload: [UInt8] = []) {
        self.init(length: payload.count + 1, id: id, payload: payload)
    }

    static func make(from data: Data) -> (message: PeerMessage?, leftBytes: [UInt8]?) {
        make(from: [UInt8](data))
    }

    static func make(from bytes: [UInt8]) -> (message: PeerMessage?, leftBytes: [UInt8]?) {
        guard bytes.count > 4 else { return (nil, bytes) }
        let lengthBytes = Array(bytes[0..<4])

        if lengthBytes == keepAlive {
            return make(from: Array(bytes.dropFirst(4)))
        }

        guard
            let size = UInt32(lengthBytes)?.bigEndian,
            let id = MessageID(rawValue: bytes[4]),
            id.validate(length: size)
        else {
            return (nil, bytes)
        }

        let length = Int(size)
        let rawPayload = bytes.dropFirst(5)
        let payload = Array(rawPayload.prefix(length - 1))
        let left = Array(rawPayload.dropFirst(length - 1))
        let result = PeerMessage(length: length, id: id, payload: payload)

        if left.isEmpty {
            return (result, nil)
        }

        return (result, left)
    }
}

struct PeerMessageError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}

extension PeerMessage {
    static func makeRequest(index: Int, begin: Int, length: Int) -> PeerMessage {
        let payload = [index, begin, length].reduce([UInt8](), { $0 + UInt32($1).bigEndian.bytes })
        return .init(id: .request, payload: payload)
    }

    static func makeHave(index: Int) -> PeerMessage {
        return .init(id: .have, payload: UInt32(index).bigEndian.bytes)
    }

    func parsePiece(index: Int, buffer: inout [UInt8]) throws -> Int {
        if id != .piece {
            throw PeerMessageError("Expected PIECE, got ID \(id)")
        }

        if payload.count < 8 {
            throw PeerMessageError("Payload too short. \(payload.count) < 8")
        }

        guard let value = UInt32(payload[0..<4])?.byteSwapped else {
            throw PeerMessageError("Fail to attempt parse index")
        }

        let parsedIndex = Int(value)

        if parsedIndex != index {
            throw PeerMessageError("Expected index \(index), got \(parsedIndex)")
        }

        guard let value = UInt32(payload[4..<8])?.byteSwapped else {
            throw PeerMessageError("Fail to attempt parse begin offset")
        }

        let begin = Int(value)

        if begin >= buffer.count {
            throw PeerMessageError("Begin offset invalid. \(begin) >= \(buffer.count)")
        }

        let data = payload[8..<payload.count]
        let dataLength = data.count
        let end = begin + dataLength
        if end > buffer.count {
            throw PeerMessageError("Data too long \(dataLength) for offset \(begin) with length \(buffer.count)")
        }

        buffer.replaceSubrange(begin..<end, with: data)
        return dataLength
    }
}
