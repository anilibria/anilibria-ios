//
//  GetTimecodesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct GetTimecodesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [TimeCodeData]

    let date = Date()
    var requestData: RequestData
    let decodingInfo: [CodingUserInfoKey : any Sendable]?

    init(since: Date?) {
        requestData = .init(
            endpoint: "/accounts/users/me/views/timecodes",
            parameters: since.map {
                ["since": ISO8601DateFormatter().string(from: $0)]
            } ?? [:]
        )
        decodingInfo = [.dateKey: date]
    }
}

extension TimeCodeData: Decodable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        episodeID = try container.decode(String.self)
        time = try container.decode(Double.self)
        isWatched = try container.decode(Bool.self)
        if let date = decoder.userInfo[.dateKey] as? Date {
            updatedAt = date
        }
    }
}

private extension CodingUserInfoKey {
    static let dateKey: CodingUserInfoKey = {
        if let key = CodingUserInfoKey(rawValue: "DATE_KEY") {
            return key
        }
        fatalError("unexpected")
    }()
}
