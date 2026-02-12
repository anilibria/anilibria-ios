//
//  Torrent.swift
//  Anilibria
//
//  Created by Иван Морозов on 23.02.2020.
//  Copyright © 2020 Иван Морозов. All rights reserved.
//

import Foundation

public struct Torrent: Codable, Hashable {
    let id: Int
    let torrentHash: String
    let size: Int64
    let type: DescribedValue<TorrentType>?
    let label: String
    let magnet: String
    let filename: String
    let seeders: Int
    let leechers: Int
    let completed: Int
    let description: String
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case torrentHash = "hash"
        case size
        case type
        case label
        case magnet
        case filename
        case seeders
        case leechers
        case completed = "completed_times"
        case description
        case updatedAt = "updated_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateConverter = DateConverter()
        id = try container.decode(required: .id)
        torrentHash = container.decode(.torrentHash) ?? ""
        size = container.decode(.size) ?? 0
        type = container.decode(.type)
        label = container.decode(.label) ?? ""
        magnet = container.decode(.magnet) ?? ""
        filename = container.decode(.filename) ?? ""
        seeders = container.decode(.seeders) ?? 0
        leechers = container.decode(.leechers) ?? 0
        completed = container.decode(.completed) ?? 0
        description = container.decode(.description) ?? ""
        updatedAt = dateConverter.convert(from: container.decode(.updatedAt))
    }

    public func encode(to encoder: Encoder) throws {
        let dateConverter = DateConverter()
        encoder.apply(CodingKeys.self) { container in
            container[.id] = id
            container[.torrentHash] = torrentHash
            container[.size] = size
            container[.type] = type
            container[.label] = label
            container[.magnet] = magnet
            container[.filename] = filename
            container[.seeders] = seeders
            container[.leechers] = leechers
            container[.completed] = completed
            container[.description] = description
            container[.updatedAt] = dateConverter.convert(from: updatedAt)
        }
    }
}

public enum TorrentType: String, Codable {
    case bdRip = "BDRip"
    case hdRip = "HDRip"
    case tvRip = "TVRip"
    case webRip = "WEBRip"
    case dtvRip = "DTVRip"
    case dvdRip = "DVDRip"
    case hdtvRip = "HDTVRip"
    case webDLRip = "WEB-DLRip"
}
