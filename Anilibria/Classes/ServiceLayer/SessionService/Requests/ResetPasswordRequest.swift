//
//  ResetPasswordRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct ResetPasswordRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/auth/password/reset",
        method: .POST
    )

    init(token: String, password: String) {
        requestData.body = [
            "token": token,
            "password": password,
            "password_confirmation": password
        ]
    }
}
