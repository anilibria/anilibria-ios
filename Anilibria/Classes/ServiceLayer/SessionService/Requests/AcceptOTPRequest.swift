//
//  AcceptOTPRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct AcceptOTPRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData = .init(
        endpoint: "/accounts/otp/accept",
        method: .POST
    )

    init(code: String) {
        requestData.body = ["code": code]
    }
}
