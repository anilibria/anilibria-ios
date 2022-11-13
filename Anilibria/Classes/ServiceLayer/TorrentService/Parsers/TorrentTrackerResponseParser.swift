//
//  TorrentTrackerResponseParser.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentTrackerResponseParser {
    enum ResponseError: Error {
        case empty
        case failure(message: String)
    }

    private let parser = BencodeParser()

    func parse<T: BencodeDecodable>(from data: Data?) throws -> T {
        guard let data = data else { throw ResponseError.empty }

        let bencode = try parser.parse(data)

        if let result = T(from: bencode) {
            return result
        }

        if let reason = bencode["failure reason"]?.text {
            throw ResponseError.failure(message: reason)
        }

        throw ResponseError.failure(message: "fail to parse \(T.self)")
    }
}
