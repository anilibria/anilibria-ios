//
//  SaveTimecodesRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

public struct SaveTimecodesRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/views/timecodes",
        method: .POST
    )

    init(items: [TimeCodeData]) {
        requestData.body = items
    }
}

extension TimeCodeData: Encodable {
    public func encode(to encoder: any Encoder) throws {
        encoder.apply(CodingKeyString.self) { container in
            container["release_episode_id"] = episodeID
            container["is_watched"] = isWatched
            container["time"] = time
        }
    }
}
