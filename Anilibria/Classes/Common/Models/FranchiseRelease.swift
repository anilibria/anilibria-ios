//
//  FranchiseRelease.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

struct FranchiseRelease: Hashable, Decodable {
    let id: String
    let franchiseID: String
    let series: Series?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let dateConverter = DateConverter()
        let urlConverter = URLConverter(Configuration.imageServer)
        self.id = try container.decode(required: "id")
        self.franchiseID = try container.decode(required: "franchise_id")
        self.series = container.decode("release")
    }
}
