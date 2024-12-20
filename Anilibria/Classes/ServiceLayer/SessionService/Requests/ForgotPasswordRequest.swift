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

    let endpoint: String = "/accounts/users/auth/password/forget"
    let method: NetworkManager.Method = .POST
    let body: (any Encodable)?

    init(email: String) {
        body = ["email": email]
    }
}
