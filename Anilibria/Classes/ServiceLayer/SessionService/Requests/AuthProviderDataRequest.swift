//
//  AuthProviderDataRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct AuthProviderDataRequest: BackendAPIRequest {
    typealias ResponseObject = AuthProviderData

    var requestData: RequestData

    init(provider: AuthProvider, baseUrl: URL) {
        requestData = .init(
            endpoint: "/accounts/users/auth/social/\(provider.rawValue)/login",
            parameters: ["host": baseUrl.absoluteString]
        )
    }
}
