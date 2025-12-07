//
//  ForgotPasswordRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ForgotPasswordRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/auth/password/forget",
        method: .POST
    )

    init(email: String) {
        requestData.body = ["email": email]
    }
}
