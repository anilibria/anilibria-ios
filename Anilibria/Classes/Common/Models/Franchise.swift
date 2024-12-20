//
//  Franchise.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

struct Franchise: Hashable, Decodable {
    let id: String
    let name: String
    let nameEnglish: String
    let image: URL?
    let releases: [FranchiseRelease]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let urlConverter = URLConverter(Configuration.imageServer)
        self.id = try container.decode(required: "id")
        self.name = container.decode("name") ?? ""
        self.nameEnglish = container.decode("name_english") ?? ""
        self.image = urlConverter.convert(from: container.decode("image", "preview"))
        self.releases = container.decode("franchise_releases") ?? []
    }
}
