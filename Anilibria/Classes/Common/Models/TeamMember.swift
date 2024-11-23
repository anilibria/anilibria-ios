//
//  TeamMember.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

struct TeamGroup {
    let team: TeamMember.Team
    let members: [TeamMember]

    init(team: TeamMember.Team, members: [TeamMember]) {
        self.team = team
        self.members = members.sorted(by: { $0.sortOrder < $1.sortOrder })
    }
}

struct TeamMember: Decodable, Hashable {
    struct Team: Decodable, Hashable {
        let title: String
        let description: String?
        let sortOrder: Int

        fileprivate init() {
            title = ""
            description = nil
            sortOrder = Int.max
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeyString.self)
            title = container.decode("title") ?? ""
            sortOrder = container.decode("sort_order") ?? 0
            description = container.decode("description")
        }
    }

    struct Role: Decodable, Hashable {
        let title: String?
        let sortOrder: Int

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeyString.self)
            title = container.decode("title")
            sortOrder = container.decode("sort_order") ?? 0
        }
    }

    let id: String
    let name: String
    let isVacation: Bool
    let isIntern: Bool
    let roles: [Role]
    let team: Team
    let sortOrder: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        id = try container.decode(required: "id")
        name = container.decode("nickname") ?? ""
        isVacation = container.decode("is_vacation") ?? false
        isIntern = container.decode("is_intern") ?? false
        roles = container.decode("roles") ?? []
        team = container.decode("team") ?? Team()
        sortOrder = container.decode("sort_order") ?? 0
    }
}
