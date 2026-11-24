//
//  PromoRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct PromoRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [PromoItem]

    var requestData: RequestData = .init(
        endpoint: "/media/promotions"
    )
}
