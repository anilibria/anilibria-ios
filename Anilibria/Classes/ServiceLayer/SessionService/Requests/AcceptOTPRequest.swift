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

    let endpoint: String = "/accounts/otp/accept"
    let method: NetworkManager.Method = .POST
    let body: (any Encodable)?
    var headers: [String : String] = [:]

    init(code: String) {
        self.body = ["code": code]
    }
}
