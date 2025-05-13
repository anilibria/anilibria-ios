//
//  UserCollectionData.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct UserCollectionData: Codable {
    public let seriesID: Int
    public let collectionType: UserCollectionType?

    public init(seriesID: Int, collectionType: UserCollectionType) {
        self.seriesID = seriesID
        self.collectionType = collectionType
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        seriesID = try container.decode(Int.self)
        collectionType = try container.decodeIfPresent(UserCollectionType.self)
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeyString.self) { values in
            values["release_id"] = seriesID
            values["type_of_collection"] = collectionType
        }
    }
}
