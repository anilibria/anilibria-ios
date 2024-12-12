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

    let endpoint: String = "/accounts/users/auth/password/reset"
    let method: NetworkManager.Method = .POST
    let body: (any Encodable)?

    init(token: String, password: String) {
        body = [
            "token": token,
            "password": password,
            "password_confirmation": password
        ]
    }
}
