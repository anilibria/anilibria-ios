//
//  Sorting.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

struct Sorting: Decodable {
    let id: String
    let name: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        id = try container.decode(required: "value")
        name = container.decode("label") ?? ""
    }
}
