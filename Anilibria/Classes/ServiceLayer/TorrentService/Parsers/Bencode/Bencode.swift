//
//  Bencode.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

protocol BencodeDecodable {
    init?(from value: BencodeValue)
}

enum BencodeValue {
    case number(Int, slice: [UInt8])
    case text(String, slice: [UInt8])
    case list([BencodeValue], slice: [UInt8])
    case object([String: BencodeValue], slice: [UInt8])

    var text: String? {
        if case let .text(value, _) = self {
            return value
        }
        return nil
    }

    var number: Int? {
        if case let .number(value, _) = self {
            return value
        }
        return nil
    }

    var list: [BencodeValue]? {
        if case let .list(value, _) = self {
            return value
        }
        return nil
    }

    var slice: [UInt8]? {
        switch self {
        case .number(_, let slice):
            return slice
        case .text(_, let slice):
            return slice
        case .list(_, let slice):
            return slice
        case .object(_, let slice):
            return slice
        }
    }

    subscript(name: String) -> BencodeValue? {
        if case let .object(value, _) = self {
            return value[name]
        }
        return nil
    }

}

enum BencodeError: Error {
    case wrongStructure
    case empty
}

class BencodeParser {
    struct Symbols {
        // d
        static let dictionary: UInt8 = 0x64
        // l
        static let list: UInt8 = 0x6c
        // i
        static let number: UInt8 = 0x69
        // :
        static let separator: UInt8 = 0x3a
        // e
        static let end: UInt8 = 0x65
    }

    func parse(_ data: Data?) throws -> BencodeValue {
        guard let data = data, !data.isEmpty else { throw BencodeError.empty }
        var cursor: Int = 0
        return try parseValue(cursor: &cursor, data: [UInt8](data))
    }

    private func parseValue(cursor: inout Int, data: [UInt8]) throws -> BencodeValue {
        if let dict = try parseDictionary(cursor: &cursor, data: data) {
            return dict
        }

        if let list = try parseList(cursor: &cursor, data: data) {
            return list
        }

        if let number = parseNumber(cursor: &cursor, data: data) {
            return number
        }

        if let text = parseText(cursor: &cursor, data: data) {
            return text
        }

        throw BencodeError.wrongStructure
    }

    private func parseDictionary(cursor: inout Int, data: [UInt8]) throws -> BencodeValue? {
        var value = data[cursor]

        if value != Symbols.dictionary {
           return nil
        }

        let startIndex = cursor

        cursor = data.index(after: cursor)
        value = data[cursor]

        var result: [String: BencodeValue] = [:]

        while value != Symbols.end {
            guard case .text(let key, _) = parseText(cursor: &cursor, data: data) else {
                return nil
            }

            result[key] = try parseValue(cursor: &cursor, data: data)
            value = data[cursor]
        }

        let slice = Array(data[startIndex...cursor])

        cursor = data.nextIndexIfNotLast(after: cursor)

        return .object(result, slice: slice)
    }

    private func parseList(cursor: inout Int, data: [UInt8]) throws -> BencodeValue? {
        var value = data[cursor]

        if value != Symbols.list {
           return nil
        }

        let startIndex = cursor

        cursor = data.index(after: cursor)
        value = data[cursor]

        var result: [BencodeValue] = []

        while value != Symbols.end {
            result.append(try parseValue(cursor: &cursor, data: data))
            value = data[cursor]
        }

        let slice = Array(data[startIndex...cursor])

        cursor = data.nextIndexIfNotLast(after: cursor)

        return .list(result, slice: slice)
    }

    private func parseText(cursor: inout Int, data: [UInt8]) -> BencodeValue? {
        let original = cursor
        var value = data[cursor]
        let symbol = makeString([value]).first

        if symbol?.isNumber != true {
            cursor = original
            return nil
        }

        var characters: [UInt8] = []
        while value != Symbols.separator {
            characters.append(value)
            cursor = data.index(after: cursor)
            value = data[cursor]
        }

        guard let lenght = Int(makeString(characters)) else {
            cursor = original
            return nil
        }

        cursor = data.index(after: cursor)
        let start = cursor
        cursor = data.index(cursor, offsetBy: lenght)
        let slice = Array(data[start..<cursor])
        return .text(makeString(slice), slice: slice)
    }

    private func parseNumber(cursor: inout Int, data: [UInt8]) -> BencodeValue? {
        let original = cursor
        var value = data[cursor]
        if value != Symbols.number {
            return nil
        }

        let startIndex = cursor

        cursor = data.index(after: cursor)
        value = data[cursor]

        var characters: [UInt8] = []
        while value != Symbols.end {
            characters.append(value)
            cursor = data.index(after: cursor)
            value = data[cursor]
        }

        let slice = Array(data[startIndex...cursor])
        cursor = data.nextIndexIfNotLast(after: cursor)

        if let result = Int(makeString(characters)) {
            return .number(result, slice: slice)
        }
        cursor = original
        return nil
    }

    private func makeString<T: Collection<UInt8>>(_ bytes: T) -> String {
        String(data: Data(bytes), encoding: .utf8) ?? ""
    }
}

private extension Array {
    func nextIndexIfNotLast(after value: Int) -> Int {
        if value == endIndex {
            return value
        }
        return index(after: value)
    }
}
