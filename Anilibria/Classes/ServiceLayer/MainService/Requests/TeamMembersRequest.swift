//
//  TeamMembersRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct TeamMembersRequest: BackendAPIRequest {
    typealias ResponseObject = [TeamMember]

    let endpoint: String = "/teams/users"
    let method: NetworkManager.Method = .GET
}
